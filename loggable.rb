module Loggable
  def self.included(base)
    base.extend(ClassMethods)
  end

  def log(message, *args, level: :info)
    text = format message, *args
    self.class.logger.send(level, text)
  end

  def append(message, *args)
    text = format message, *args
    self.log_buffer += text
  end

  def flush(message, *args, level: :info)
    append message, *args
    log(log_buffer, level:)
    self.log_buffer = ''
  end

  module ClassMethods
    def set_logger(logger)
      @logger = logger
    end

    def logger
      @logger
    end
  end

  private

  def log_buffer
    @log_buffer ||= ''
  end

  def log_buffer=(text)
    @log_buffer = text
  end
end
