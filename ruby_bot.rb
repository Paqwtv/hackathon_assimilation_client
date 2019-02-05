class RubyBot
  def self.turn(client, turn_number)
    if client.not_my_planets.length > 0 && client.not_my_planets.length < 2
      to_planet = client.not_my_planets[0]
    else
      to_planet = client.not_my_planets[0]
      to_planet2 = client.not_my_planets[1]
    end
    for planet in client.my_planets
      if planet.value > 1
        client.send(planet, to_planet, 1) if to_planet
        client.send(planet, to_planet2, 1) if to_planet2
      end
    end
    client.end_turn
  end
end
