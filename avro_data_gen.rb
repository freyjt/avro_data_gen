# Setup an object from an avro schema and
#  write it out
class AvroDataGenerator
  attr_reader :build
  def initialize(schema_path)
    @build = {} #will be actually mutated
    schema_str = File.open(schema_path, 'r').read
    @schema = JSON.parse(schema_str)
  end

  def fill_out



  end
end