require 'json'

class Airline_seating_algorithm
  attr_accessor :exceed_booking, :max_seats, :passengers_count, :input_message

  def initialize(*args)
    # Intialise input arguments user
    @input_message = validate_input
    if @input_message.nil?
      @max_seats = @input_seats.inject(0) { |sum, x| sum += x[0] * x[1] }
      @exceed_booking = true if @max_seats < @passengers_count
      @max_columns = @input_seats.map(&:last).max
      @allocated_passengers = 0
    end
  end

  def seating_arrangement
    arrange_seats
    fill_aisle_seats
    fill_window_seats
    fill_center_seats
  end

  def validate_input
    # To take input from user
    puts "Please enter seating structure in 2D array (For ex: [ [3,2], [4,3], [2,3], [3,4] ]) :"
    @input = gets()
    puts "Please enter total passengers count (For ex: 30) : "
    @count = gets.chomp

    puts "Please enter 2D array input as the first argument!" if @input.strip.empty?
    puts "Please enter Number of passengers as the second argument!" if @count.nil? || @count.strip.empty?
    begin
      @input_seats = JSON.parse(@input)
    rescue
      puts "The first argument is invalid! Please input a 2D array."
    end
    puts "Invalid input ! Please enter array in 2D format!" unless @input_seats.all? { |x| x.is_a?(Array) }
    puts "All the sub-arrays of the given 2D array must be [x,y] format!" unless @input_seats.all? { |x| x.size == 2 }
    puts "The sub-arrays are in [x,y] format but '-' and 'y' should be NON-ZERO values!" if @input_seats.any? { |x| x.any?(0) }
    begin
      @passengers_count = JSON.parse(@count)
    rescue
      puts "Invalid Input! Please enter the valid number of passengers."
    end
    puts "Invalid Input! The second argument should be a positive integer" unless @passengers_count.is_a?(Integer)
  end

  private

  def arrange_seats
    @available_seats = @input_seats.each_with_object([]).with_index do |(arr, seats), index|
      seats << (1..arr[1]).map { |x| Array.new(arr[0]) { 'N' } }
    end
    @sorted_seats = (1..@max_columns).each_with_object([]).with_index do |(x, arr), index|
      arr << @available_seats.map { |x| x[index] }
    end
  end

  def fill_aisle_seats
    @aisle_seats = @sorted_seats.each_with_object([]) do |element_array, result_array|
      result_array << if element_array.nil?
        nil
      else
        element_array.each_with_object([]).with_index do |(basic_element_array, update_arr), index|
          update_arr << if basic_element_array.nil?
            nil
          else
            if index == 0
              @allocated_passengers += 1
              basic_element_array[-1] = @allocated_passengers <= @passengers_count ? @allocated_passengers.to_s.rjust(@max_seats.to_s.size, "0") : '-'*@max_seats.to_s.size
            elsif index == element_array.size - 1
              unless basic_element_array.size == 1
                @allocated_passengers += 1
                basic_element_array[0] = @allocated_passengers <= @passengers_count ? @allocated_passengers.to_s.rjust(@max_seats.to_s.size, "0") : '-'*@max_seats.to_s.size
              end
            else
              @allocated_passengers += 1
              basic_element_array[0] = @allocated_passengers <= @passengers_count ? @allocated_passengers.to_s.rjust(@max_seats.to_s.size, "0") : '-'*@max_seats.to_s.size
              unless basic_element_array.size == 1
                @allocated_passengers += 1
                basic_element_array[-1] = @allocated_passengers <= @passengers_count ? @allocated_passengers.to_s.rjust(@max_seats.to_s.size, "0") : '-'*@max_seats.to_s.size
              end
            end
            basic_element_array
          end
        end
      end
    end
  end

  def fill_window_seats
    @window_seats = @aisle_seats.each_with_object([]) do |element_array, result_array|
      result_array << if element_array.nil?
        nil
      else
        element_array.each_with_object([]).with_index do |(basic_element_array, update_arr), index|
          update_arr << if basic_element_array.nil?
            nil
          else
            if index == 0
              @allocated_passengers += 1
              basic_element_array[0] = @allocated_passengers <= @passengers_count ? @allocated_passengers.to_s.rjust(@max_seats.to_s.size, "0") : '-'*@max_seats.to_s.size
            elsif index == element_array.size - 1
              @allocated_passengers += 1
              basic_element_array[-1] = @allocated_passengers <= @passengers_count ? @allocated_passengers.to_s.rjust(@max_seats.to_s.size, "0") : '-'*@max_seats.to_s.size
            end
            basic_element_array
          end
        end
      end
    end
  end

  def fill_center_seats
    @center_seats = @window_seats.each_with_object([]) do |element_array, result_array|
      result_array << if element_array.nil?
        nil
      else
        element_array.each_with_object([]).with_index do |(basic_element_array, update_arr), index|
          update_arr << if basic_element_array.nil?
            nil
          else
            if basic_element_array.size > 2
              (1..basic_element_array.size - 2).each do |x|
                @allocated_passengers += 1
                basic_element_array[x] = @allocated_passengers <= @passengers_count ? @allocated_passengers.to_s.rjust(@max_seats.to_s.size, "0") : '-'*@max_seats.to_s.size
              end
            end
            basic_element_array
          end
        end
      end
    end
  end
end
# To pass dynamic input entered by user to the user_input.txt file.
f = File.new('user_input.txt', 'w')
f = File.open('user_input.txt', 'w')
f.puts @input
f.puts @count
f.close
lines = File.readlines('user_input.txt')

seats_arrangement = Airline_seating_algorithm.new(lines)
if seats_arrangement.input_message.nil?
  puts "Sorry! Seats are not available... #{seats_arrangement.passengers_count} for passengers.\
   Only #{seats_arrangement.max_seats} seats are available!" if seats_arrangement.exceed_booking
  output = seats_arrangement.seating_arrangement
    output.each_with_index do |row, parent_index|
      row_formatted = ''
      row.each_with_index do |arr, index|
        if index == row.size - 1
          output_print = arr.inspect.gsub(',', '').gsub('"', '')
        else
          output_print = arr.inspect.gsub(',', '').gsub('"', '') + ' '
        end
        if parent_index == 0
          instance_variable_set("@arr_length_#{index}", output_print.length)
        else
          output_print = " " * instance_variable_get("@arr_length_#{index}").to_i if output_print.strip == 'nil'
        end
        row_formatted += output_print
      end
      puts row_formatted
    end
else
  puts seats_arrangement.input_message
end