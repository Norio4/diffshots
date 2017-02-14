#!/usr/bin/ruby

# Norio-YHT

require 'rubygems'
require 'optparse'
require 'selenium-webdriver'
require 'yaml'
require "rubygems"
require "rmagick"
require 'date'
require 'fileutils'



def save_screenshot(filename, path, num)
  @driver.save_screenshot("#{path}#{filename}")
end

def url_access(url, src, num)
  num = num
  url_src = url
  begin
    @driver.navigate.to url_src
  rescue
    STDERR.print "There is something wrong about #{url_src}\n"
    return "n"
  end
  re_url_src = url.sub(/http:\/\/|https:\/\//,"").gsub('.',"").gsub("/","_").sub(/html|jsp|com|nejp|cojp|jp/,"")
  file_name = "#{re_url_src}_#{src}_#{num}.png"
  if src == "origin"
    path = "public/images/#{@arg_dir_path}/origin/"
  else
    path = "public/images/#{@arg_dir_path}/comparison/"
  end
  save_screenshot(file_name,path, num)
  return file_name
end

def auth_url_access(url, src, num, auth_dict)
  STDOUT.puts "Sorry this programs don't support basic authorication now."
  STDOUT.puts "We will support basic authorication in the near future."
  num = num
  url_src = url
  begin
    @driver.navigate.to url_src
  rescue
    STDERR.print "There is something wrong about #{url_src}\n"
    return "n"
  end
  re_url_src = url.sub(/http:\/\/|https:\/\//,"").gsub('.',"").gsub("/","_").sub(/html|jsp|com|nejp|cojp|jp/,"")
  file_name = "#{re_url_src}_#{src}_#{num}.png"
  if src == "origin"
    path = "public/images/#{@arg_dir_path}/origin/"
  else
    path = "@iblic/images/#{@arg_dir_path}/comparison/"
  end
  save_screenshot(file_name,path, num)
  return file_name
end

def image_diff_rate(image)
  i = 0.0
  black = Magick::Pixel.new(0,0,0,0)
  for y in 0...image.rows
    for x in 0...image.columns
      image_color = image.pixel_color(x, y)
      if image_color == black
      else
        i = i + 1
      end
    end
  end
  pix = i
  i = i / (image.rows * image.columns) * 100
  STDOUT.puts i.round(2).to_s + "%, #{pix} pixels"
  return i.round(2).to_s + "%, #{pix} pixels"
end

def make_diff_images(imgs)
  origin = imgs[0]
  comparison = imgs[1]
  diff = origin.composite(comparison, 0, 0, Magick::DifferenceCompositeOp)
  double_diff = diff.composite(origin, 0, 0, Magick::DifferenceCompositeOp)
  return diff, double_diff
end


def make_diff_image_and_log(origin_img_path_name, compari_img_path_name, num, file)
 
  imgs = Magick::ImageList.new(origin_img_path_name, compari_img_path_name)  
  diff, result_image = make_diff_images(imgs)
  now = Time.now.to_s.gsub("-", "").gsub(/(\+.*)/,"").gsub(/(\s$)/, "").gsub(" ", "-")
  ## calculate diff rate
  diff_rate = image_diff_rate(diff)
  diff_log = now +"," +origin_img_path_name + "-" + compari_img_path_name + "," + diff_rate
  file.puts diff_log

  result_image.write("tmp_image.png")
  system("mv tmp_image.png #{@diff_path}/diff_result_#{num}.png")
end

def check_authorication(dict)
  return false if dict["authentication"].nil?
  return false if dict["authentication"]["username"].nil?
  return false if dict["authentication"]["password"].nil?
  return true
end

def diff_urls(origin_dict, comparison_dict)
  file =  File.open("./imagediff.log", "a")
  loops = origin_dict["urls"].length
  loops.times do |x|
    url_o = origin_dict["urls"][x]
    url_c = comparison_dict["urls"][x]
    if check_authorication(origin_dict) == true
      o_path = auth_url_access(url_o, "origin", x, origin_dict["authorication"])
      next if o_path == "n"
      o_path = @origin_path + "/" + o_path
      c_path = auth_url_access(url_c, "comparison", x, comparison_dict["authorication"])
      next if c_path == "n"
      c_path = @comparison_path + "/" + c_path
    else
      o_path = url_access(url_o, "origin", x)
      next if o_path == "n"
      o_path = @origin_path + "/" + o_path
      c_path = url_access(url_c, "comparison", x)
      next if c_path == "n"
      c_path = @comparison_path + "/" + c_path
    end
    make_diff_image_and_log(o_path, c_path, x, file)
  end
  file.close
  #STDOUT.puts "All Done!!"
end

def check_dir
  #FileUtils.mkdir_p(@arg_dir_path) unless FileTest.exist?(@arg_dir_path)
  FileUtils.mkdir_p(@origin_path) unless FileTest.exist?(@origin_path)
  FileUtils.mkdir_p(@comparison_path) unless FileTest.exist?(@comparison_path)
  FileUtils.mkdir_p(@diff_path) unless FileTest.exist?(@diff_path)
end

def check_args(arg, m=false)
  arg = arg
  arg = arg.gsub("../", "")
  if m == false
    path = arg.sub(".yml","")
    @arg_dir_path = path
    return true
  end
  return false unless arg =~ /yml$/
  path = arg.sub(".yml","")
  @arg_dir_path = path
  return true
end

def load_yml(arg)
  begin
    yml = YAML.load_file(arg)
  rescue
   return "Error invalid yaml Syntax\n"
  end
  return "Error there is no 'origin'\n" if yml["origin"].nil?
  return "Error there is no 'comparison'\n" if yml["comparison"].nil?
  return "Error there is no 'origin/urls'\n" if yml["origin"]["urls"].nil?
  return "Error there is no 'comparison/urls'\n" if yml["comparison"]["urls"].nil?
  return yml
end




opt = OptionParser.new()
opt.version=("1.0")
options = {}
opt.on("-f" ,"--filename <params>.<params>,..", "select using yaml files, unlless all yaml files in current directory.", Array){|v| options[:f] = v}
opt.on("-b", "--browser <params>", "select using browser that have to be installed, default is firefox. ") {|v| options[:b] = v}
opt.parse!(ARGV)

a = %x[ ps ]
if md = a.match(/Xvfb/)
else
  system("Xvfb :1 -screen 0 1024x768x24 &")
end

p options

case options[:b]
when "chrome"
  @driver = Selenium::WebDriver.for :chrome 
when "opera"
  @driver = Selenium::WebDriver.for :opera
when "firefox"
  @driver = Selenium::WebDriver.for :firefox 
when "ie"
  @driver = Selenium::WebDriver.for :ie
when nil
  @driver = Selenium::WebDriver.for :firefox 
else
  STDERR.print "Error. Not support browser.\n"
  exit!
end


unless options[:f].nil?
  args = options[:f]
  args.each do |a|
    if check_args(a, true) == true
      yml = load_yml(a)
      if yml[0] == "E"
        STDERR.print yml
      else
        @diff_path = "public/images/#{@arg_dir_path}/diffs"
        @origin_path = "public/images/#{@arg_dir_path}/origin"
        @comparison_path = "public/images/#{@arg_dir_path}/comparison"
        check_dir
        STDOUT.puts "Validations are clear"
        STDOUT.puts "Start access urls and mage diff images ..... "
        origins = yml["origin"]
        comparisons = yml["comparison"]
        diff_urls(origins, comparisons)
      end
    else
      STDERR.print "Error Invalid argments\n"
    end
  end
else
  dir = Dir.glob("./*.yml") 
  dir.each do |d|
    check_args(d,true)
    yml = load_yml(d)
    if yml[0] == "E"
      STDERR.print yml
    else
      @diff_path = "public/images/#{@arg_dir_path}/diffs"
      @origin_path = "public/images/#{@arg_dir_path}/origin"
      @comparison_path = "public/images/#{@arg_dir_path}/comparison"
      check_dir
      STDOUT.puts "Start access urls and mage diff images ..... "
      origins = yml["origin"]
      comparisons = yml["comparison"]
      diff_urls(origins, comparisons)
    end
  end
end
