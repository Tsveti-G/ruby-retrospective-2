class PrivacyFilter
  attr_accessor :preserve_phone_country_code
  attr_accessor :preserve_email_hostname
  attr_accessor :partially_preserve_email_username

  def initialize(text)
    @text = text
    preserve_phone_country_code = false
    preserve_email_hostname = false
    partially_preserve_email_username = false
  end

  def filtered
    if partially_preserve_email_username == true then @text = username_filtered(1) end
    if preserve_email_hostname == true then @text = email_filtered(0) end
    if preserve_phone_country_code == true then @text = phone_filtered(1) end
    simply_filtered
  end

  def username_filtered(flag)
    host = '(@([a-zA-Z0-9][a-zA-Z0-9-]{,60}[a-zA-Z0-9]?\.)+[a-zA-Z]{2,3}(\.[a-zA-Z])?)'
    if (name = (/([a-zA-Z0-9][a-zA-Z0-9_\+\.-]{,200})#{host}/.match @text)) == nil or $1.size < 6 or flag == 0
      email_filtered(flag)
    else
      result = name.pre_match + $1[0,3] + '[FILTERED]' + $2 + PrivacyFilter.new(name.post_match).username_filtered(flag)
    end
  end

  def email_filtered(flag)
    name = /[a-zA-Z0-9][a-zA-Z0-9_\+\.-]{,200}/.match @text
    if (host = /(@([a-zA-Z0-9][a-zA-Z0-9-]{,60}[a-zA-Z0-9]?\.)+[a-zA-Z]{2,3}(\.[a-zA-Z])?)/.match @text) and name != nil
      result = name.pre_match + '[FILTERED]' + $1 + PrivacyFilter.new(host.post_match).username_filtered(flag)
    else
      @text
    end
  end

  def phone_filtered(flag)
    phone = /((00|\+)[1-9]\d{0,2})(([-\(\)\s]{0,2}\d){6,11})/.match @text
    if phone == nil or flag == 0
      simply_phone_filtered(flag)
    else
      result = phone.pre_match + $1 + ' [FILTERED]' + PrivacyFilter.new(phone.post_match).phone_filtered(flag)
    end
  end

  def simply_filtered
    result = simply_email_filtered
    PrivacyFilter.new(result).simply_phone_filtered(1)
  end

  def simply_phone_filtered(flag)
    phone = /((((00|\+)[1-9]\d{0,2})|0)([-\(\)\s]{0,2}\d){6,11})/.match @text
    if phone != nil
      result = phone.pre_match + '[PHONE]' + PrivacyFilter.new(phone.post_match).phone_filtered(flag)
    else
      @text
    end
  end

  def simply_email_filtered
    hostname = /(([a-zA-Z0-9][a-zA-Z0-9-]{,60}[a-zA-Z0-9]?\.)+[a-zA-Z]{2,3}(\.[a-zA-Z])?)/.match @text
    if (name = /([a-zA-Z0-9][a-zA-Z0-9_\+\.-]{,200}@)/.match @text) != nil and hostname != nil
      result = PrivacyFilter.new(name.pre_match).filtered + '[EMAIL]' + PrivacyFilter.new(hostname.post_match).filtered
    else
      @text
    end
  end
end

class Validations
  def Validations.email?(value)
    if (name = /\A[a-zA-Z0-9][a-zA-Z0-9_\+\.-]{,200}@/.match value) and
        Validations.hostname?(name.post_match)
      true
    else
      false
    end
  end

  def Validations.phone?(value)
    if /\A(((00|\+)[1-9]\d{0,2})|0)([-\(\)\s]{0,2}\d){6,11}\z/ =~ value
      true
    else
      false
    end
  end

  def Validations.hostname?(value)
    if /\A([a-zA-Z0-9][a-zA-Z0-9-]{0,60}[a-zA-Z0-9]?\.)+[a-zA-Z]{2,3}(\.[a-zA-Z])?\z/ =~ value
      true
    else
      false
    end
  end

  def Validations.ip_address?(value)
    if (ip = /\A(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})\z/.match value) and
  ip[1].split('.').map{ |number| Integer(number) < 256 }.count{ |item| item == true } == 4
      true
    else
      false
    end
  end

  def Validations.number?(value)
    if /\A-?((0(\.\d+)?)|[1-9]\d*(\.\d+)?)\z/ =~ value
      true
    else
      false
    end
  end

  def Validations.integer?(value)
    if /\A-?(0|[1-9]\d*)\z/ =~ value
      true
    else
      false
    end
  end

  def Validations.date?(value)
    if (match = /\A(\d{4}-\d{2}-\d{2})\z/.match value)
      date = match[1].split('-').map{ |number| Integer(number) }
      date[1] > 0 and date[1] < 13 and date[2] > 0 and date[2] < 32
    end
  end

  def Validations.time?(value)
    if (match = /\A(\d{2}:\d{2}:\d{2})\z/.match value)
      time = match[1].split(':').map{ |number| Integer(number) }
      time[0] >= 0 and time[0] <24 and time[1] >= 0 and time[1] < 60 and time[2] >= 0 and time[2] < 60
    end
  end

  def Validations.date_time?(value)
    if (Validations.date?(value.split[0]) and Validations.time?(value.split[1])) or
       (Validations.date?(value.split('T')[0]) and Validations.time?(value.split('T')[1]))
      true
    else
      false
    end
  end
end
