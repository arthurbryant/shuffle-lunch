#!/usr/bin/env ruby

require 'csv'

module Shuffle
  MAX_GROUP_NUMBER = 6.0

  def generate(file_name)
    id_slack_hash = Hash.new
    divisions, staff_num = create_divisions(file_name, id_slack_hash)

    puts divisions
    puts
    puts id_slack_hash

    lunch_groups = make_groups(divisions, staff_num)
    groups = Hash.new
    lunch_groups.each do  |k, v|
      arr = v.map {|i| id_slack_hash[i]}
      groups[k] = arr
    end
    groups
  end

  def create_divisions(file_name, id_slack_hash)
    groups = Hash.new
    staff_num = 0

    CSV.foreach(file_name, headers: 'true', skip_blanks: true) do |row|
      div_name = row[0]
      staff_no = row[3]
      slack = row[8]
      email = row[9]

      staff_num += 1
      # FIXME: header is included.
      next if staff_num == 1
      # Ignore people without email.
      if email
        id_slack_hash[staff_no] = slack
        if groups[div_name].nil?
          groups[div_name] = [staff_no]
        else
          groups[div_name].push(staff_no)
        end
      end
    end

    # Merge 'Retail Tech' and 'RetailTech' to one group
    if groups['Retail Tech'] && groups['RetailTech']
      groups['Retail Tech'] += groups['RetailTech']
      groups.delete('RetailTech')
    end
    return groups, staff_num
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


  def make_groups(divisions, staff_num)
    index = 0
    lunch_group = Hash.new

    while divisions.any?
      lunch_group[index] = [] if lunch_group[index].nil?
      size = lunch_group[index].size
      staff_no = get_staff(divisions, staff_num, size)
      lunch_group[index] += staff_no

      if size >= MAX_GROUP_NUMBER
        puts "group #{index}: #{lunch_group[index]}"
        index += 1
        next
      end
    end

    lunch_group
  end

  def get_staff(divisions, staff_num, size)
    staff_arr = []
    keys = divisions.keys.sample(MAX_GROUP_NUMBER)
    biggest_division_key = get_key_of_biggest_division(divisions)
    keys = keys.unshift(biggest_division_key).uniq
    keys.each do |k|
      tmp = get_one(divisions, k, staff_num)
      if (staff_arr.size + size) >= MAX_GROUP_NUMBER
        return staff_arr
      end

      staff_arr += tmp
      remove_selected(divisions, k, tmp)
    end

    staff_arr
  end

  def get_one(divisions, key, staff_num)
    request_num = (divisions[key].size.to_f / staff_num * MAX_GROUP_NUMBER).ceil
    divisions[key].sample(request_num)
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

  module_function :generate, :create_divisions, :get_key_of_biggest_division, :make_groups, :get_staff, :get_one, :remove_selected

end

