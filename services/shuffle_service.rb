require 'csv'
# TODO
# 1. pass group size to lib
# 2. pass two factors for algorithm

class ShuffleService < BaseService

  def initialize(file_path:, group_size:, config_path:)
    @file_path = file_path
    @group_size = group_size.try(:to_i) || 6
    @config_path = config_path
  end

  def call
    @staff_num = CSV.read(@file_path, headers: true, skip_blanks: true).length - 1
    ap "Staff number is #{@staff_num}"

    @config = YAML::load_file(@config_path)
    divisions = generate_divisions
    ap "These are the divisions"
    ap divisions

    groups = generate_groups(divisions)
    output_groups(groups)
  end

  private

  # generate shuffle groups
  def generate_groups(divisions)
    # sleep 2
    index = 0
    groups = Hash.new

    while divisions.any?
      groups[index] = [] if groups[index].nil?
      ids = random_select_ids_from_all_divisions(divisions, groups[index].size)
      groups[index] += ids

      if groups[index].size >= @group_size
        # sleep 10
        puts "group_#{index}: #{groups[index]}"
        index += 1
        next
      end
    end

    groups
  end

  def random_select_ids_from_all_divisions(divisions, size)
    ids = []
    keys = divisions.keys.sample(@group_size)
    biggest_division_key = get_key_of_biggest_division(divisions)
    keys = keys.unshift(biggest_division_key).uniq
    keys.each do |key|
      ids_from_division = random_select_ids(divisions[key])
      if (ids.size + size) >= @group_size
        return ids
      end

      ids += ids_from_division
      remove_selected(divisions, key, ids_from_division)
    end

    ids
  end

  def get_key_of_biggest_division(divisions)
    key = nil
    max = 0

    divisions.each do |k, v|
      if v.size > max
        max = v.size
        key = k
      end
    end
    key
  end

  # random select ids from the division.
  def random_select_ids(division)
    # share of the division in the company
    ratio = division.size.to_f / @staff_num
    request_num = (ratio * @group_size).ceil
    division.sample(request_num)
  end

  def remove_selected(divisions, key, selected)
    # remove selected from group
    selected.each do |s|
      divisions[key].delete_if {|i| i == s }
      if divisions[key].empty?
        # remove division if division is empty
        divisions.delete(key)
      end
    end
  end

  # generate division groups base on csv file
  def generate_divisions
    divisions = Hash.new

    CSV.foreach(@file_path, headers: true, skip_blanks: true) do |row|
      row = row.to_hash.extract!(@config['id'], @config['email'], @config['division_name'])
      id = row[@config['id']]
      email = row[@config['email']]
      div_name = row[@config['division_name']]

      # Ignore people without email.
      if email
        if divisions[div_name].nil?
          divisions[div_name] = [id]
        else
          divisions[div_name].push(id)
        end
      end
    end

    # Merge 'Retail Tech' and 'RetailTech' to one division
    merge(divisions, 'Retail Tech', 'RetailTech')

    return divisions
  end

  def generate_id_account_hash
    id_account_hash = Hash.new
    CSV.foreach(@file_path, headers: true, skip_blanks: true) do |row|
      row = row.to_hash.extract!(@config['id'], @config['account'])
      id = row[@config['id']]
      account = row[@config['account']]
      id_account_hash[id] = account
    end

    id_account_hash
  end

  # merge misspelled division name
  def merge(divisions, div_name1, div_name2)
    if divisions[div_name1] && divisions[div_name2]
      divisions[div_name1] += divisions[div_name2]
      divisions.delete(div_name2)
    end
  end

  def output_groups(groups)
    groups_with_account = Hash.new
    id_account_hash = generate_id_account_hash

    groups.each do |key, ids|
      accounts = ids.map { |id| id_account_hash[id] }
      groups_with_account[key] = accounts
    end

    groups_with_account
  end
end