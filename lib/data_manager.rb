#!/opt/ruby/2.2.0/bin/ruby

$:<< File.join(File.dirname(__FILE__), '.')

require 'csv'
require 'states'

# General class to parse CSV data
class Data_Manager

  def initialize(options, project)
    @options = options
    @project = options[project.to_sym]
    @data_store = options[:data_store]
    @table = CSV.table("#{@data_store}/#{@project[:tabular_data]}")
  end

  def abbrev_states
    verify_column_headers @project[:required_headers]
    modify_to_state_code
    write_new_data 'new_rolodex'
  end
 
  def update_floor_plan
    verify_column_headers @project[:required_headers]
    reorg_cat_crates
    write_new_data 'new_floor_plan'
  end

  # Validates the required headers exist in the data source 
  # Param: columns - required columns from the config file to validate
  def verify_column_headers columns
    columns.each { |column|
      unless @table.headers.include? column.to_sym
        raise ArgumentError.new("Expected header for column not found") 
      end
    }
  end
  :private
  
  # Updates the CSV table by comparing the 'state' column to a hash, translating to the two-letter code for US states used 
  # by the USPS. If the corresponding state is not found in the map, the current existing  value is used.
  def modify_to_state_code
    @table.map { |row| ::States.has_value?(row[:state].upcase) ? row[:state] = ::States.key(row[:state].upcase) : row[:state] }
  end
  :private

  # Zips list of cats and dogs composed of 1's and 0's and then evaluate the sum of each row. If the sum of > 1, then we know 
  # a cat and dog are next to each other, so we update the table.
  def reorg_cat_crates
    cats = @table[:cat]
    dogs = @table[:dog] 
    cat_column = 0

    cats_and_dogs = cats.zip(dogs)
    cats_and_dogs.select { |row| row.inject(0, :+) > 1 }.each { |row| row[cat_column] = 0 } 
    @table[:cat], _ = cats_and_dogs.transpose 
  end
  :private

  # Writes to a new CSV file based on the data found in the table 
  # Param: filename - the name of the file to write and save
  def write_new_data filename
    modified = CSV.open("#{@data_store}/#{filename}.csv", 'w', headers: true)
    modified << @table.headers
    @table.each { |row| modified << row }
  end
  :private
    
end
