class MapObject
  attr_reader :x, :y
  attr_accessor :id, :own, :value
  def initialize(s)
    arr = s.split(",")
    @type = arr[0].to_i
    @x = arr[1].to_f
    @y = arr[2].to_f
    @value = arr[3].to_i
    @own = arr[4].to_i
    if @type == 1
      @size = arr[5].to_i
      @from_id = 0
      @to_id = 0
      @number_of_turns = 0
    else
      @size = 0
      @id = 0
      @from_id = arr[5].to_i
      @to_id = arr[6].to_i
      @number_of_turns = arr[7].to_i
    end
  end
end
