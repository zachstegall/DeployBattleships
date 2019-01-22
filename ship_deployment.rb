module Battleship
    class Ship
        attr_reader :length, :id, :name

        def initialize(id, name, length)
            @id = id
            @name = name
            @length = length
        end
    end

    SHIPS = [
        Ship.new('c', "carrier", 5),
        Ship.new('b', "battleship", 4),
        Ship.new('r', "cruiser", 3),
        Ship.new('s', "submarine", 3),
        Ship.new('d', "destroyer", 2)
    ]

    def self.random_ship(excluding = nil)
        ships = SHIPS
        ship = ships[rand(0...ships.length)]
        return ship if excluding == nil

        while excluding.include?(ship)
            ship = ships[rand(0...ships.length)]
        end

        ship
    end

    class Grid

        PLACEHOLDER = "_"
        SIZE = 10
        attr_reader :ships_deployed

        #     A  B  C  D  E  F  G  H  I  J
        #  1  _  _  _  _  _  _  _  _  _  _
        #  2  _  _  _  _  _  _  _  _  _  _
        #  3  _  _  _  _  _  _  _  _  _  _
        #  4  _  _  _  _  _  _  _  _  _  _
        #  5  _  _  _  _  _  _  _  _  _  _
        #  6  _  _  _  _  _  _  _  _  _  _
        #  7  _  _  _  _  _  _  _  _  _  _
        #  8  _  _  _  _  _  _  _  _  _  _
        #  9  _  _  _  _  _  _  _  _  _  _
        # 10  _  _  _  _  _  _  _  _  _  _

        def initialize()
            # [
            # 0  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
            # 1  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
            # 2  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
            # 3  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
            # 4  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
            # 5  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
            # 6  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
            # 7  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
            # 8  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
            # 9  [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
            # ]
            @grid = Array.new(SIZE) { Array.new(SIZE, PLACEHOLDER) }
            @ships_deployed = []
        end

        def has_deployed_all?()
            Battleship::SHIPS.each { |ship| return false unless @ships_deployed.include?(ship) }
            true
        end

        class Point
            LETTER_TO_NUMBER = { A: 1, B: 2, C: 3, D: 4, E: 5, F: 6, G: 7, H: 8, I: 9, J: 10 }

            def initialize(letter, number)
                letter_uppercased = letter.upcase

                unless LETTER_TO_NUMBER.has_key?(letter_uppercased)
                    abort("Letter not available on the grid. Use any letter between A and J.")
                end

                unless LETTER_TO_NUMBER.has_value?(number)
                    abort("Number not available on the grid. Use any number between 1 and 10.")
                end

                @letter = letter_uppercased
                @number = number
            end

            def self.letter_to_number(letter)
                LETTER_TO_NUMBER[letter]
            end

            def self.number_to_letter(num)
                result = nil
                LETTER_TO_NUMBER.each do |letter, number|
                    if num == number
                        result = letter
                        break
                    end
                end
                result
            end

            def self.random_point
                random_number = rand(1..Grid::SIZE)
                random_letter = number_to_letter(rand(1..Grid::SIZE))
                new(random_letter, random_number)
            end

            def first_dimension_index
                @number - 1
            end

            def second_dimension_index
                Point.letter_to_number(@letter) - 1
            end

            def x
                second_dimension_index
            end

            def y
                first_dimension_index
            end
        end

        class Direction
            LEFT = 1
            UP = 2
            RIGHT = 3
            DOWN = 4

            def self.random_direction
                rand(LEFT..DOWN)
            end
        end

        def ship_fits_at?(ship, point, direction)
            space_diff = (ship.length - 1)

            if direction == Direction::LEFT
                return point.x - space_diff >= 0
            elsif direction == Direction::UP
                return point.y - space_diff >= 0
            elsif direction == Direction::RIGHT
                return point.x + space_diff < Grid::SIZE
            elsif direction == Direction::DOWN
                return point.y + space_diff < Grid::SIZE
            else
                abort("This direction does not exist. See Grid::Direction for direction values.")
            end
        end

        def ship_exists_at?(ship, point, direction)
            if direction == Direction::LEFT
                ship.length.times { |num| return true if @grid[point.y][point.x - num] != Grid::PLACEHOLDER }
            elsif direction == Direction::UP
                ship.length.times { |num| return true if @grid[point.y - num][point.x] != Grid::PLACEHOLDER }
            elsif direction == Direction::RIGHT
                ship.length.times { |num| return true if @grid[point.y][point.x + num] != Grid::PLACEHOLDER }
            elsif direction == Direction::DOWN
                ship.length.times { |num| return true if @grid[point.y + num][point.x] != Grid::PLACEHOLDER }
            else
                abort("This direction does not exist. See Grid::Direction for direction values.")
            end

            false
        end

        def deploy(ship, point, direction)
            if direction == Direction::LEFT
                ship.length.times { |num| @grid[point.y][point.x - num] = ship.id }
            elsif direction == Direction::UP
                ship.length.times { |num| @grid[point.y - num][point.x] = ship.id }
            elsif direction == Direction::RIGHT
                ship.length.times { |num| @grid[point.y][point.x + num] = ship.id }
            elsif direction == Direction::DOWN
                ship.length.times { |num| @grid[point.y + num][point.x] = ship.id }
            else
                abort("This direction does not exist. See Grid::Direction for direction values.")
            end

            @ships_deployed << ship
        end

        def printgrid
            puts "    A  B  C  D  E  F  G  H  I  J"
            # puts " 1  _  _  _  _  _  _  _  _  _  _"
            @grid.length.times do |y|
                print " #{y + 1}  " if y < 9
                print "10  " if y == 9
                @grid[y].length.times do |x|
                    print "#{@grid[y][x]}  " if x < 9
                    print "#{@grid[y][x]}" if x == 9
                end
                puts
            end
        end
    end

    # Pick a ship
    # Pick a deployment point on the grid
    # Pick a direction to lay out the ship
    # Print the grid
    def self.deploy_ships
        grid = Grid.new

        while !grid.has_deployed_all?
            # Pick a ship
            ship = Battleship.random_ship(grid.ships_deployed)

            # Find a deployment point on the grid and
            # a direction to lay out the ship
            point, direction = point_and_direction(ship, grid)

            # Deploy the ship
            grid.deploy(ship, point, direction)
        end

        # Print the grid
        grid.printgrid
    end

    # Find a starting point and direction to lay out
    # the ship that fits within the grid and does not
    # overlap another ship.
    def self.point_and_direction(ship, grid)
        point = Grid::Point.random_point
        direction = Grid::Direction.random_direction
        while true
            fits = grid.ship_fits_at?(ship, point, direction)
            if fits
                break unless grid.ship_exists_at?(ship, point, direction)
            end

            point = Grid::Point.random_point
            direction = Grid::Direction.random_direction
        end

        return point, direction
    end
end
