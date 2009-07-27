require 'rvideo'

module Paperclip
  class RvideoThumbnail < Processor

    attr_accessor :offset, :options
    
    def initialize(file, options = {}, attachment = nil)
      super
      @current_format   = File.extname(@file.path)
      @basename         = File.basename(@file.path, @current_format)
      
      @offset = options[:offset]
      @options = options
    end

    def make
      unless @offset.blank?
        dst = Tempfile.new([ @basename, 'jpg' ].compact.join("."))
        dst.binmode
      
        RVideo.logger = RAILS_DEFAULT_LOGGER
        RVideo::FrameCapturer.capture! :input => file.path, :output => dst.path, :offset => @offset
        dst
        
        # go through the normal paperclip thumbnailing process too
        paperclip_thumbnail = Thumbnail.new(dst, @options, @attachment)
        paperclip_thumbnail.make
      else
        file
      end
    end
  end
end