# Setup an object from an avro schema and
#  write it out
class AvroDataGenerator
  AVRO_PRIMITIVES = %w(null boolean int long float double bytes string array).freeze
  attr_reader :build
  def initialize(schema_path)
    @build = {} #will be actually mutated
    schema_str = File.open(schema_path, 'r').read
    @schema = JSON.parse(schema_str)
  end

  #start off the recursive call
  def fill_out
    @build = {}
    descend(@schema, [])
    @build
  end

  private
  
  # recursively enter the parsed schema
  def descend(ruby_obj, name_arr)
    if ruby_obj.class == Hash
      n = name_arr.copy
      #type can be record, then we descend
      if ruby_obj['type'] == 'record' || ruby_obj['type'].class == Hash
        descend(ruby_obj['fields'], n.push ruby_obj['name'])
      elsif ruby_obj['type'].class == Array
        #can be one of many
        request_data_by(ruby_obj['type'], name_arr)
      elsif AVRO_PRIMITIVES.include?(ruby_obj['type'])
        request_data_by(ruby_obj['type'], name_arr)
      else
        raise "Descent didn't get a type or somethign idk, but it's all broken"
      end
      #type can be nil?
    else
      raise "Descent received a non-hash object, I think you're doing it wrong"
    end
  end

  def request_data_by(type, name_arr, doc)
    location = name_arr.join("::")
    puts "Gimme some data for:"
    puts location
    unless doc.nil?
      puts "Doc: #{doc}"
    end

  end
  
  def produce_on_object(value, name_arr)
    obj_string = '@object' # HAHAHAHA don't...seriously
    # !chomp the first bit, for how avro encodes/decodes
    name_arr.shift!
    name_arr.each do |new_name|
      obj_string << "['#{new_name}']"
      if eval(obj_string).nil?
        eval(obj_string) = {} # TODO this follows alllll the way down, we want until the last place so we can put in value, maybe check against last element
      end
    end

  end

  def in_gets_by(type)
    input = STDIN.gets.chomp
    case type
    when 'string', 'bytes' # bytes correct to leave here? 
                           # maybe something with md5, maybe parse hex...probably parse hex
      input
    when 'boolean'
      v = input[0,1]
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