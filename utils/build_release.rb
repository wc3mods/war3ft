#!/usr/bin/env ruby
require 'fileutils'
require 'open-uri'
require 'optparse'

class BuildService
  attr_reader :version, :amxx_version, :rebuild_image

  def initialize(version:, amxx_version:, rebuild_image: false)
    @version = version
    @amxx_version = amxx_version
    @rebuild_image = rebuild_image
    
    @root = File.expand_path(File.join(__dir__, '..'))
    @build_dir = File.join(@root, 'build')
    @build_tmp_dir = File.join(@root, 'build_tmp')
    @releases_dir = File.join(@root, 'releases')
    @amxx_dir = File.join(@root, 'amxx')
    @src_dir = File.join(@root, 'plugin_src')
    @config_dir = File.join(@root, 'amxmodx')
    @asset_dir = File.join(@root, 'hl_assets')
    @util_dir = File.join(@root, 'utils')
    @games = %w[cstrike czero dod]
  end

  def base_url
    case @amxx_version
    when /^1\.8\.2.*/
      "https://www.amxmodx.org/release/"
    when /^1\.9\.0.*/
      "https://www.amxmodx.org/amxxdrop/1.9/"
    when /^1\.10\.0.*/
      "https://www.amxmodx.org/amxxdrop/1.10/"
    else
      raise "Unsupported AMXX version: #{@amxx_version}. Must start with 1.8.2, 1.9.0, or 1.10.0"
    end
  end

  def log(msg)
    puts "[*] #{msg}"
  end

  def download_metamod
    FileUtils.mkdir_p(@amxx_dir)

    archive = "metamod-1.21.1-am.zip"
    unless File.exist?(archive)
      log "Downloading Metamod..."
      system("wget https://www.amxmodx.org/release/#{archive}")
    end

    if File.exist?(archive)
      system("unzip -qo #{archive} -d #{@amxx_dir}")
    end

    # Copy plugins.ini to the metamod directory in AMXX_DIR
    FileUtils.cp(File.join(@util_dir, 'metamod', 'plugins.ini'), File.join(@amxx_dir, 'addons', 'metamod', 'plugins.ini'))
  end

  def download_amxx(game = "base")
    FileUtils.mkdir_p(@amxx_dir)

    game = "cstrike" if game == "czero"

    # https://www.amxmodx.org/release/amxmodx-1.8.2-cstrike-linux.tar.gz
    # Download and extract Windows assets
    windows_archive = "amxmodx-#{@amxx_version}-#{game}-windows.zip"
    unless File.exist?(windows_archive)
      log "Downloading Windows AMXX #{@amxx_version}..."
      system("wget #{base_url}/#{windows_archive}")
    end

    if File.exist?(windows_archive)
      system("unzip -qo #{windows_archive} -d #{@amxx_dir}")
    end

    # Download and extract Linux assets
    linux_archive = "amxmodx-#{@amxx_version}-#{game}-linux.tar.gz"
    unless File.exist?(linux_archive)
      log "Downloading Linux AMXX #{@amxx_version}..."
      system("wget #{base_url}/#{linux_archive}")
    end

    if File.exist?(linux_archive)
      system("tar -xzf #{linux_archive} -C #{@amxx_dir}")
    end
  end

  def build_docker_image
    return unless @rebuild_image
    log "Building AMXXPC Docker image..."
    unless system(<<~CMD)
      docker build \
        -t amxxpc \
        -f Dockerfile.amxxpc .
    CMD
      raise "ERROR: Failed to build Docker image"
    end
  end

  def compile_plugins
    build_docker_image

    output_dir = "#{@build_tmp_dir}/addons/amxmodx/plugins/"

    FileUtils.mkdir_p(output_dir)
    puts "Creating #{output_dir}"

    log "Compiling war3ft.sma..."

    unless system(<<~CMD)
      docker run --rm \
        -v "#{@root}:/workspace" \
        -w "/opt/addons/amxmodx/scripting" \
        -e AMXX_BASE_URL="#{base_url}" \
        -e AMXX_VERSION="#{@amxx_version}" \
        amxxpc
    CMD
      raise "ERROR: Docker compile failed for war3ft.sma"
    end

    scripting_path = "#{@build_tmp_dir}/addons/amxmodx/scripting"
    FileUtils.mkdir_p(scripting_path)

    FileUtils.cp("#{@src_dir}/war3ft.sma", File.join(scripting_path, "war3ft.sma"))
    FileUtils.cp_r("#{@src_dir}/war3ft", scripting_path)
  end

  def copy_plugin_files
    # Create base addons directory
    addons_dir = File.join(@build_tmp_dir, "addons")
    amxmodx_dir = File.join(addons_dir, "amxmodx")
    FileUtils.mkdir_p(amxmodx_dir)

    # Copy configs
    src = File.join(@config_dir, "configs")
    FileUtils.cp_r(src, amxmodx_dir)

    # Copy data
    src = File.join(@config_dir, "data")
    FileUtils.cp_r(src, amxmodx_dir)
  end

  def copy_hl_assets
    %w[sound sprites wc3.css].each do |entry|
      src = File.join(@asset_dir, entry)
      dest = File.join(@build_tmp_dir, entry)
      FileUtils.cp_r(src, dest, remove_destination: true) if File.exist?(src) || Dir.exist?(src)
    end
  end

  def create_zip(name:, paths: nil, build_dir: @build_dir)
    zip_name = File.join(@releases_dir, "#{name}.zip")
    log "Creating #{zip_name}..."

    Dir.chdir(build_dir) do
      if paths.nil?
        system("zip -qr #{zip_name} *")
      else
        system("zip -qr #{zip_name} #{paths.join(' ')}")
      end
    end
  end

  def create_main_zips
    # Create plugin zip with everything
    create_zip(name: "war3ft-v#{@version}-plugin-amxmodx-#{@amxx_version}", build_dir: @build_tmp_dir)
    
    # Create client files zip with just the assets
    FileUtils.rm_rf("#{@build_dir}/addons")  # Temporarily remove addons folder
    create_zip(name: "war3ft-v#{@version}-client-files", paths: %w[sound sprites wc3.css], build_dir: @build_tmp_dir)
    copy_plugin_files  # Restore the addons folder
  end

  def enable_module(module_name)
    path = File.join(@amxx_dir, 'addons', 'amxmodx', 'configs', 'modules.ini')

    # Read the file and remove the ; from the line containing the module name
    lines = File.readlines(path)
    lines.each do |line|
      if line.include?(module_name)
        line.gsub!(';', '')
      end
    end

    # Write the modified lines back to the file
    File.write(path, lines.join)
  end

  def create_addons_zips
    @games.each do |game|
      log "Building addons-#{game}-#{@amxx_version} zip..."
      
      # Clean up previous AMXX downloads and builds
      FileUtils.rm_rf(@amxx_dir)
      FileUtils.rm_rf(Dir.glob("#{@amxx_dir}/*"))

      FileUtils.rm_rf(Dir.glob("#{@build_dir}/*"))

      # Extract AMXX for the base/game
      download_amxx("base")
      download_amxx(game)
      download_metamod

      # Update addons/amxmodx/config/plugins.ini to have war3ft.amxx debug at the end of the file
      File.open(File.join(@amxx_dir, 'addons', 'amxmodx', 'configs', 'plugins.ini'), 'a') do |file|
        file.puts "war3ft.amxx debug"
      end

      # Enable required modules
      enable_module("fun")
      enable_module("engine")
      enable_module("fakemeta")
      enable_module("nvault")
      enable_module("mysql")

      if game == "cstrike" || game == "czero"
        enable_module("cstrike")
        enable_module("csx")
      elsif game == "dod"
        enable_module("dod")
      end

      # Copy the correct liblist.gam
      src = File.join(@util_dir, game, 'liblist.gam')
      FileUtils.cp(src, @build_dir)

      # Copy amxx to BUILD_DIR
      FileUtils.cp_r(Dir.glob("#{@amxx_dir}/*"), @build_dir)

      # Copy from BUILD_TMP_DIR to BUILD_DIR
      FileUtils.cp_r(Dir.glob("#{@build_tmp_dir}/*"), @build_dir)

      zip_name = File.join(@releases_dir, "war3ft-v#{@version}-#{game}-amxmodx-#{@amxx_version}.zip")
      Dir.chdir(@build_dir) do
        system("zip -qr #{zip_name} *")
      end
    end
  end

  def clean
    FileUtils.rm_rf(Dir.glob("#{@build_dir}/*"))
    FileUtils.rm_rf(Dir.glob("#{@build_tmp_dir}/*"))
    FileUtils.mkdir_p(@releases_dir)
  end

  def run
    Dir.chdir(@root) do
      clean
      download_amxx
      download_metamod
      compile_plugins
      copy_plugin_files
      copy_hl_assets
      create_main_zips
      create_addons_zips
      log "Done!"
    end
  end
end

# Parse command line arguments
options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} --version VERSION --amxx-version AMXX_VERSION [--rebuild-image]"
  
  opts.on("-v", "--version VERSION", "Version number for the release") do |v|
    options[:version] = v
  end

  opts.on("-a", "--amxx-version AMXX_VERSION", "AMXX version to use (e.g. 1.10.0-git5467)") do |v|
    options[:amxx_version] = v
  end

  opts.on("-r", "--rebuild-image", "Rebuild the Docker image") do |v|
    options[:rebuild_image] = v
  end
end.parse!

# Validate required options
unless options[:version]
  puts "ERROR: Version is required"
  puts "Example: #{$0} --version 3.0.1 --amxx-version 1.10.0-git5467 [--rebuild-image]"
  exit 1
end

# Check if version matches war3ft.sma
war3ft_version = File.readlines(File.join(__dir__, '..', 'plugin_src', 'war3ft.sma'))
                    .find { |line| line.include?('new const WC3VERSION[]') }
                    &.match(/"([^"]+)"/)&.[](1)

unless war3ft_version == options[:version]
  puts "ERROR: Specified version #{options[:version]} does not match version in war3ft.sma (#{war3ft_version})"
  exit 1
end

# Clean up previous releases from previous runs
root = File.expand_path(File.join(__dir__, '..'))
release_dir = File.join(root, 'releases')
FileUtils.rm_rf(Dir.glob("#{release_dir}/*"))

if options[:amxx_version]
  service = BuildService.new(
    version: options[:version],
    amxx_version: options[:amxx_version],
    rebuild_image: options[:rebuild_image]
  )
  service.run
else
  # Build for all AMXX versions
  ["1.8.2", "1.9.0-git5294", "1.10.0-git5467"].each do |amxx_version|
    service = BuildService.new(
      version: options[:version],
      amxx_version: amxx_version,
      rebuild_image: options[:rebuild_image]
    )
    service.run
  end
end
