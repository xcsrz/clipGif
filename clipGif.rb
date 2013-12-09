#!/usr/bin/ruby

require 'tmpdir'
require 'fileutils'

##### SETTINGS #####
regifFilename = 'reGif.command'
openCommand = "open anim.gif -a /Applications/Chromium.app"
outputFilenamePrevix = "anim"

##### METHDOS #####
def usage
	puts "","\t#{File.basename(__FILE__)} InputFile StartTime Length [FrameDelay] [rewind]",""
	puts "\t* Both StartTime and Length must be in the format ##:##:##",""
	exit
end
def reqd(prog)
	len = 40
	str = "#{prog} is required by is not installed or in your path"
	len = str.length + 6 if str.length > 34
	str = "## " + str + (" " * (len - 6 - str.length)) + " ##"
	puts "#" * len, str , "#" * len
	puts len
end
def prog(msg)
	puts "  -->> #{msg}"
end
def avail?(name)
  `which #{name}`
  $?.success?
end

##### PREREQ CHECK #####
prereqs = FALSE
['ffmpeg','gifsicle'].each do |r|
	unless avail? r
		reqd r 
		prereqs = TRUE
	end
end
if prereqs 
	puts "", "\t-->> cannot proceed without dependencies","\t-->> ... quiting",""
	exit
end

## Are we valid?
if ARGV.length < 3 || ! File.exists?(ARGV[0]) || ! ARGV[1].match(/\d\d\:\d\d\:\d\d/) || ! ARGV[2].match(/\d\d\:\d\d\:\d\d/) then
	usage
end

## Do work, son! YOU GOTTA DO WORK!!
(inputFile, startTime, length, delay, rewind) = ARGV
delay = delay.nil? ? 2 : delay

prog "Making temp directory"
tmpdir = Dir.mktmpdir
origdir = Dir.getwd
prog "(temp dir is #{tmpdir}"
	system "open #{tmpdir}"

prog "Breaking out frames"
system "ffmpeg -i \"#{inputFile}\" -ss #{startTime} -t #{length} #{tmpdir}/out%08d.gif"


prog "Moving into temp directory"
Dir.chdir tmpdir

if rewind then
	prog "Creating rewind"
	frames = Dir.glob('*.gif')
	sn = frames.length
	fn = sn + 1
	sn.times do |n|
	  next unless File.exists?(sprintf('out%08d.gif',sn - n))
	  system "cp #{ sprintf('out%08d.gif',sn - n)} #{ sprintf('out%08d.gif',fn + n)}"
	end
end

prog "Assempling frames into gif"
gifsicleCommand = "gifsicle --delay=#{delay} --loop *.gif > anim.gif"
system gifsicleCommand


prog "Saving finished file"
n=1
outputFilenamePrevix = 'anim'
while File.exists?("#{origdir}/#{outputFilenamePrevix}#{n.to_s}.gif")
	n += 1
end
copyCommand = "cp anim.gif #{origdir}/#{outputFilenamePrevix}#{n.to_s}.gif"
system copyCommand

prog "Opening file"
system openCommand

prog "Creating script to remake (this is if you decide to remove any frames)"
File.open(regifFilename,'w') do |file|
	file.puts "#!/bin/bash","cd #{tmpdir}","rm anim.gif",gifsicleCommand,openCommand,copyCommand
end
File.chmod(0755,regifFilename)

