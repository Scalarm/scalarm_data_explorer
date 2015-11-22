class String
  def is_number?
    true if Float(self) rescue false
  end
end

class TextReader

  def initialize(text)
    text_to_predict = text.gsub("\r\n","\n")
    @split_text = text_to_predict.split("\n")
  end

  def lines
    @split_text.count - 1
  end

  def textData
    secondLine = @split_text[1]
    Rails.logger.debug("secondLine: #{secondLine}")
    secondLine.split(',').each { | element |
      return true if(!element.is_number?)
    }
    return false
  end

end