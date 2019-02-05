require 'socket'
require_relative './map_object.rb'

class Client
  attr_reader :not_my_planets, :my_planets, :ships_speed, :all_planets, :enemy_planets, :neutral_planets, :all_ships, :my_ships, :stream
  attr_accessor :should_stop, :out, :in

  def initialize(bot, ip_address, port)
    # planets
    @all_planets = []
    @neutral_planets = []
    @not_my_planets = []
    @my_planets = []
    @enemy_planets = []
    # ships
    @all_ships = []
    @my_ships = []
    @enemy_ships = []
    @in = nil
    @out = nil
    @bot = bot
    @port = port.to_i
    @turn_number = 0
    @ships_speed = 0.04  # default value
    @should_stop = false
    @ip_address = ip_address
  end

  def run
    connection = false
    while !connection
      begin
        puts "Connecting: #{@ip_address}, port: #{@port}"
        @socket = TCPSocket.open(@ip_address, @port)
        @in = @socket.recv(1638400)
        @socket.close if @should_stop
        connection = true
        puts 'Connected'
      rescue StandardError => e
        puts(e)
        sleep(2)
      end
    end
    run_stream if connection
  end

  def run_stream
    StreamReader.new(@in, self).run
  end

  def listen
    @in = @socket.recv(1638400)
    run_stream
  end

  def send_data
    @socket.write(@out)
  end

  def parse_meta(s)
    arr = s.split("#")
    if arr.length > 1
      ps = arr[1].split(";")
      @ships_speed = ps[0].to_f
      @turn_number = ps[1].to_i
    end
  end

  def parse_objects(s)
    arr = s.split('#')
    map_object_list = []
    if arr.length > 1
      ps = arr[1].split(';') if arr[1]
      ps.each_with_index do |x,n|
        obj = MapObject.new(x)
        obj.id = n
        map_object_list.push(obj) if obj
      end
    end
    if arr[0].include? 'planets'
      @all_planets = []
      @my_planets = []
      @not_my_planets = []
      @enemy_planets = []
      @neutral_planets = []
      for x in map_object_list
        @all_planets.push(x)
        if x.own == 0
          @neutral_planets.push(x)
          @not_my_planets.push(x)
        elsif x.own == 1
          @my_planets.push(x)
        elsif x.own == 2
          @enemy_planets.push(x)
          @not_my_planets.push(x)
        end
      end
    elsif arr[0].include? 'ships'
      @all_ships = []
      @enemy_ships = []
      @my_ships = []
      for x in map_object_list
        @all_ships.push(x)
        if x.own == 1
          @my_ships.push(x)
        elsif x.own == 2
          @enemy_ships.push(x)
        end
      end
    end
  end

  def add_buffer(s)
    s_len = s.length
    ([0xff & (s_len >> 8), (0xff & s_len)].pack('U*') + s).force_encoding("utf-8")#.bytes.to_a
  end

  def stop
    @should_stop = true
  end

  def turn
    @bot.turn(self, @turn_number)
  end

  # game methods
  def send(from_obj, to_obj, count)
    @out = add_buffer("#send:#{from_obj.id},#{to_obj.id},#{count}")
    from_obj.value -= count
    send_data
  end

  def end_turn
    @out = add_buffer('#endTurn')
    send_data
    listen
  end

  def distance(from_obj, to_obj)
    x = to_obj.x - from_obj.x
    y = to_obj.y - from_obj.y
    Math.sqrt(x*x + y*y)
  end

  def turns_from_to(from_obj, to_obj)
    distance = distance(from_obj, to_obj)
    turns = distance / @ships_speed
    int_turns = turns.to_i
    if turns > int_turns
      int_turns += 1
    end
    int_turns
  end
end

class StreamReader
  def initialize(s_read, client)
    @read = s_read
    @client = client
  end

  def run
    line = @read
    while line
      if line.include? 'stop'
        @client.socket.close
        line = nil
      else
        arr = line.split(':').reject(&:empty?)
        @client.parse_objects(arr[0])
        @client.parse_objects(arr[1])
        @client.parse_meta(arr[2])
        @client.turn
      end
    end
  end
end
