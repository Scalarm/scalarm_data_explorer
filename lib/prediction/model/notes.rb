class Notes

  @@notes = [ "Hints are only suggestions",
              "If you blindly provide many specific arguments, there will be many hints and few or non-specific advices",
              "If you provide few specific arguments, there will be many specific advices (which will not be accurate) but not so many hints" ]

  def self.get_general_notes
    @@notes
  end

end