class String
  def is_number?
    true if Float(self) rescue false
  end
end

class FileReader

  def initialize(fileName)
    @fileName = File.dirname(__FILE__) + '/'+ fileName
  end

  def lines
    File.readlines(@fileName).count - 1
  end

  def textData
    secondLine = File.readlines(@fileName)[1]
    secondLine.split(',').each { | element |
        return true if(!element.is_number?)
    }
    return false
  end

end


########################################################################################################################
#reader = FileReader.new("../input.csv")
#raise "Wrong answer of counting lines" unless reader.lines == 108
#raise "Wrong answer of checking if labeled data is existing" unless reader.textData