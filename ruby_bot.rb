require 'pry'

class RubyBot

  class << self

    def turn(client, turn_number)


        my_planets_value = client.my_planets.size
        enemy_planets_value = client.enemy_planets.size
        enemy_ships_val = client.enemy_planets.map(&:value)
        all_my_ships_val = client.my_planets.map(&:value)

        # capture_three_planet(client) if (0..3).include?(turn_number)
          client.my_planets.each do |my_planet|
            na_planets(client, my_planet).sort_by {|el| el[:ships] }.each do |target|
              if target[:own] == 'netral'
                client.send(my_planet, target[:object], target[:ships] + 1)
              else
                ships = target[:size].equal?(2) ? (target[:ships] + (target[:turns] * 2) + 1) : (target[:ships] + 1 + target[:turns])
                p ships
                client.send(my_planet, target[:object], ships)
              end
              next
              # send_to_one_target(client, my_planet[:object], enemy_planets(client, my_planet[:object]).sort_by { |el| el[:ships]}.first )
              # send_to_one_target(client, my_planet[:object], na_planets(client, my_planet[:object]).sort_by { |el| el[:ships]}.first )
              # elsif my_planet[:object].value > target[:ships] + 1
              #   client.send(my_planet[:object], target[:object], target[:ships] + 1 )
              # else
              #   send_to_one_target(client, my_planet[:object], na_planets(client, my_planet[:object]).sort_by { |el| el[:ships]}.first )
              #   send_to_one_target(client, my_planet[:object], enemy_planets(client, my_planet[:object]).sort_by { |el| el[:ships]}.first )
              # end
            end
          end

          # if my_planets_value > 3
          #   all_planets(client, my_planet).sort_by {|el| el[:turns] }.each do |target|
          #     ships_fot_zahvat = target[:ships] + 1 + target[:turns]
          #     if planet_ships > ships_fot_zahvat
          #       client.send(my_planet, target[:object], ships_fot_zahvat)
          #     elsif planet_ships > target[:ships] + 1
          #       client.send(my_planet, target[:object], target[:ships] + 1 )
          #     else
          #       next
          #     end
          #   end
          # elsif my_planets_value > enemy_planets_value
          #   perspective_planet(client).each do |my_planet1|
          #     enemy_planets(client, my_planet1[:object]).sort_by {|el| el[:ships] }.each do |target|
          #       ships_fot_zahvat = target[:ships] + 1 + target[:turns]
          #       if my_planet1.value > ships_fot_zahvat
          #         client.send(my_planet1[:object], target[:object], ships_fot_zahvat)
          #       elsif my_planet1.value > target[:ships] + 1
          #         client.send(my_planet1[:object], target[:object], target[:ships] + 1 )
          #       else
          #         send_to_one_target(client, my_planet1[:object], enemy_planets(client, my_planet1[:object]).sort_by { |el| el[:ships]}).first
          #       end
          #     end
          #   end
          # else
          #   perspective_planet(client).each do |my_planet|
          #     send_to_one_target(client, my_planet[:object], (na_planets(client, my_planet[:object]).sort_by { |el| el[:ships]}).first )
          #   end
          # end
        client.end_turn
    end

    def na_planets(client, my_planet)
      res = []
      client.not_my_planets.each do |na_planet|
        not_my_planet = {}
        not_my_planet[:object] = na_planet
        not_my_planet[:from_my_planet] = my_planet.id
        not_my_planet[:turns] = client.turns_from_to(my_planet, na_planet)
        not_my_planet[:ships] = na_planet.value
        not_my_planet[:own] = na_planet.own == 0 ? 'netral' : 'enemy'
        not_my_planet[:size] = na_planet.size

        res << not_my_planet
      end
      res.uniq
    end

    def capture_three_planet(client)
      targets = []
      client.my_planets.each do |my_planet|
        na_planets(client, my_planet).sort_by { |el| el[:turns] }.each do |target|
          t = {}
          t[:object] = target[:object]
          t[:capture_ships] = (target[:ships] + 1)
          targets << t
        end
        client.send(my_planet, targets[0][:object], targets[0][:capture_ships])
        client.send(my_planet, targets[1][:object], targets[1][:capture_ships]) if my_planet.value > targets[1][:capture_ships]
        client.send(my_planet, targets[2][:object], targets[2][:capture_ships]) if my_planet.value > targets[2][:capture_ships]
      end
    end

    def send_to_min_value(client)
      targets = []
      client.my_planets.each do |my_planet|
        na_planets(client, my_planet).sort_by { |el| el[:ships] }.each do |target|
          t = {}
          t[:object] = target[:object]
          t[:capture_ships] = (target[:ships] + 1)
          targets << t
        end
        ships_enemy(client).each do

        end
        client.send(my_planet, targets[0][:object], targets[0][:capture_ships])
        client.send(my_planet, targets[1][:object], targets[1][:capture_ships])
        client.send(my_planet, targets[2][:object], targets[2][:capture_ships])
      end
    end

    # def send(client, my_planet, targets)
    #   client.send(my_planet, target[:object], 1)
    # end

    def send_to_one_target(client, my_planet, target)
      client.send(my_planet, target[:object], target[:ships] + 1)
    end

    def ships_enemy(client)
      res = []
      (client.my_ships - client.enemy_ships).each do |enemy_ship|
        ship = {}
        ship[:to_id] = enemy_ship.to_id
        ship[:from_id] = enemy_ship.from_id
        ship[:value] = enemy_ship.value
        ship[:number_of_turns] = enemy_ship.number_of_turns
        res << ship
      end
      res
    end

    def perspective_planet(client)
      res = []
      client.my_planets.each do |my_planet|
        planet = {}
        planet[:value] = my_planet.value
        planet[:object] = my_planet
        res << planet
      end
      res.sort_by { |el| el[:value] }.reverse
    end

    def enemy_planets(client, my_planet)
      res = []
      client.enemy_planets.each do |na_planet|
        not_my_planet = {}
        not_my_planet[:object] = na_planet
        not_my_planet[:from_my_planet] = my_planet.id
        not_my_planet[:turns] = client.turns_from_to(my_planet, na_planet)
        not_my_planet[:ships] = na_planet.value
        res << not_my_planet
      end
      res.uniq
    end

    def all_planets(client, my_planet)
      res = []
      client.not_my_planets.each do |na_planet|
        not_my_planet = {}
        not_my_planet[:object] = na_planet
        not_my_planet[:from_my_planet] = my_planet.id
        not_my_planet[:turns] = client.turns_from_to(my_planet, na_planet)
        not_my_planet[:ships] = na_planet.value
        res << not_my_planet
      end
      res.uniq
    end

    def find_enemy_wit_min_value(client, _turn_number)
      tttargets = {}
      client.e
    end

    def prepare_target(client, turn_number, planet)
      tttargets = {}
      if turn_number < 5
        targets = find_easy_planet(client, planet).map.with_index { |val, index| [index, val] }.to_h
        targets.sort_by {|_key, val| val }.take(5).to_h.each do |k, _v|
          tttargets[client.not_my_planets[k]] = client.not_my_planets[k].value
        end
      else
        targets = find_easy_enemy(client, planet).map.with_index { |x, i| [i, x] }.to_h
        targets.sort_by {|_key, val| val }.to_h.each do |k, _v|
          tttargets[client.not_my_planets[k]] = client.not_my_planets[k].value
        end
      end
      tttargets
    end

    def enemy_ships(client, turn_number)
      client.all_ships - client.my_ships
    end


    def find_easy_planet(client, pl)
       planets = client.not_my_planets.each_with_object([]) do |planet, arr|
        arr << client.turns_from_to(planet, pl)
       end
      planets
      # planets.rindex(planets.min)
    end

    def find_easy_enemy(client, pl)
      planets = client.enemy_planets.each_with_object([]) do |planet, arr|
        arr << client.turns_from_to(planet, pl)
      end
      planets
    end

  end

end
