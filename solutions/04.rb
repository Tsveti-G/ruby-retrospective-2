module Patterns
  TLD           = /\b[a-z]{2,3}(\.[a-z]{2})?\b/i
  HOSTNAME_PART = /\b[0-9A-Za-z]([0-9a-z\-]{,61}[0-9A-Za-z])?\b/i
  DOMAIN        = /\b#{HOSTNAME_PART}\.#{TLD}\b/i
  HOSTNAME      = /\b(#{HOSTNAME_PART}\.)+#{TLD}\b/i
  EMAIL         = /\b(?<username>[a-z0-9][\w_\-+\.]{,200})@(?<hostname>#{HOSTNAME})\b/i
  COUNTRY_CODE  = /[1-9]\d{,2}/
  PHONE_PREFIX  = /((\b|(?<![\+\w]))0(?!0)|(?<country_code>\b00#{COUNTRY_CODE}|\+#{COUNTRY_CODE}))/
  PHONE         = /(?<prefix>#{PHONE_PREFIX})(?<number>[ \-\(\)]{,2}(\d[ \-\(\)]{,2}){6,10}\d)\b/
  ISO_DATE      = /(?<year>\d{4})-(?<month>\d\d)-(?<day>\d\d)/
  ISO_TIME      = /(?<hour>\d\d):(?<minute>\d\d):(?<second>\d\d)/
end

class PrivacyFilter
  attr_accessor :preserve_phone_country_code
  attr_accessor :preserve_email_hostname
  attr_accessor :partially_preserve_email_username

  def initialize(text)
    @text = text
  end

  def filtered
    phone_filtered email_filtered @text
  end

  def email_filtered(text)
    text.gsub Patterns::EMAIL do
      email_filtered_flags $~[:username], $~[:hostname]
    end
  end

  def email_filtered_flags(username, hostname)
    if preserve_email_hostname or partially_preserve_email_username
      "#{filtered_email_username(username)}@#{hostname}"
    else
      '[EMAIL]'
    end
  end

  def filtered_email_username(username)
    if partially_preserve_email_username and username.length >= 6
      username[0..2] + '[FILTERED]'
    else
      '[FILTERED]'
    end
  end
  
  def phone_filtered(text)
    text.gsub Patterns::PHONE do
      filtered_phone_number $~[:country_code]
    end
  end
  
  def filtered_phone_number(country_code)
    if preserve_phone_country_code and country_code.to_s != ''
      "#{country_code} [FILTERED]"
    else
      '[PHONE]'
    end
  end
end

class Validations
  class << self
    def email?(value)
      value =~ /\A#{Patterns::EMAIL}\z/
    end

    def phone?(value)
      value =~ /\A#{Patterns::PHONE}\z/
    end

    def hostname?(value)
      value =~ /\A#{Patterns::HOSTNAME}\z/
    end

    def ip_address?(value)
      if value =~ /\A(\d+)\.(\d+)\.(\d+)\.(\d+)\z/
        $~.captures.all? { |byte| (0..255).include? byte.to_i }
      end
    end

    def number?(value)
      value =~ /\A-?(0|[1-9]\d*)(\.[0-9]+)?\z/
    end

    def integer?(value)
      value =~ /\A-?(0|[1-9]\d*)\z/
    end

    def date?(value)
      if value =~ /\A#{Patterns::ISO_DATE}\z/
        month, day = $~[:month].to_i, $~[:day].to_i
        (1..12).include?(month) and (1..31).include?(day)
      end
    end

    def time?(value)
      if value =~ /\A#{Patterns::ISO_TIME}\z/
        hour, minute, second = $~[:hour].to_i, $~[:minute].to_i, $~[:second].to_i
        (0..23).include?(hour) and (0..59).include?(minute) and (0..59).include?(second)
      end
    end

    def date_time?(value)
      if value =~ /\A(?<date>#{Patterns::ISO_DATE})[ T](?<time>#{Patterns::ISO_TIME})\z/
        date, time = $~[:date], $~[:time]
        date?(date) and time?(time)
      end
    end
  end
end
