# Setup an object from an avro schema and
#  write it out
class AvroDataGenerator
  PRIMITIVES = %w(null boolean int long float double bytes string array).freeze
  attr_reader :build
  def initialize(schema_path)
    @build = {} # will be actually mutated
    schema_str = File.open(schema_path, 'r').read
    @schema = JSON.parse(schema_str)
  end

  # start off the recursive call
  def fill_out
    @build = {}
    descend(@schema, [])
    @build
  end

  private

  # recursively enter the parsed schema
  def descend(ruby_obj, name_arr)
    raise 'Must receive hash object' unless ruby_obj.class == Hash

    n = name_arr.copy
    # type can be record, then we descend
    if ruby_obj['type'] == 'record' || ruby_obj['type'].class == Hash
      descend(ruby_obj['fields'], n.push(ruby_obj['name']))
    elsif ruby_obj['type'].class == Array
      # can be one of many
      request_array_data(ruby_obj['type'], name_arr, ruby_obj['doc'])
    elsif PRIMITIVES.include?(ruby_obj['type'])
      request_data_by(ruby_obj['type'], name_arr, ruby_obj['doc'])
    else
      raise "Descent didn't get a type or somethign idk, but it's all broken"
    end
    # type can be nil?
  end

  def request_array_data(array, name_arr, doc)
    location = name_arr.join('::')
    puts 'Gimme some data for:'
    puts location
    unless doc.nil?
      puts "Doc: #{doc}"
    end
    puts "It should be a #{type}"
    intermediary = in_gets_by(type)
    while intermediary == false # NO NO NO NO, did you forget the way this works?
      puts "No good, I need a #{type}"
      intermediary = in_gets_by(type)
    end
    set_value_on_build(input, name_arr)
  end

  def get_array_data_type(array)
    abbr = array.map(|member| member[0,2])
    puts "Please enter the first two letters of the data-type"
    input = STDIN.gets
    # ABUSE THE CALL STACK NOOB, AT LEAST IT ISN'T A WHILE
    (abbr.include?(input[0,2].to_lower)) ? input : get_array_data_type(array)
  end

  def request_data_by(type, name_arr, doc)
    location = name_arr.join('::')
    puts 'Gimme some data for:'
    puts location
    unless doc.nil?
      puts "Doc: #{doc}"
    end
    puts "It should be a #{type}"
    intermediary = in_gets_by(type)
    while intermediary == false # NO NO NO NO, did you forget the way this works?
      puts "No good, I need a #{type}"
      intermediary = in_gets_by(type)
    end
    set_value_on_build(input, name_arr)
  end

  def set_value_on_build(value, descent_arr)
    place_value(value, @build, descent_arr)
  end

  def place_value(value, object, descent_arr)
    next_loc = descent_arr.shift
    placer = object[next_loc].nil? ? {} : object[next_loc]
    object[next_loc] = descent_arr.empty? ? value : placer
    place_value(value, object[next_loc], descent_arr) unless descent_arr.empty?
  end

  def in_gets_by(type)
    input = STDIN.gets.chomp
    case type
    when 'string', 'bytes' # bytes correct to leave here? Could Take md5 or parse hex
      input
    when 'boolean'
      v = input[0, 1]
      if v == 't' || v == 'T'
        true
      elsif v == 'f' || v == 'F'
        false
      else
        re_request_input(type, name_descent)
      end
    when 'int', 'long'
      # invalid conversions do not raise, check against prior
      v = input.to_i
      v.to_s == input ? v : re_request_input(type, name_descent)
    when 'float', 'double'
      v = input.to_f
      v.to_s == input ? v : re_request_input(type, name_descent)
    when 'array'
      # TODO
    end
  end
end

# Observations
#  ** Top level name is not used in the ruby object that is generated during decode
