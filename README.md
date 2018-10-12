# shuffle-lunch
Generate groups for shuffle lunch. The algorithm is trying to make group with people from different division as much as possible.
 
# Requirement
 - ruby 2.3.3
 - Rails 5.2
# Run
```ruby
git clone git@github.com:arthurbryant/shuffle-lunch.git
./bin/rails db:migrate
./bin/rails s
```

access http://localhost:3000/lunches

# Usage
- Set up your company.yml by reference to config/shuffle/company.yml
- Choose group size, default is 6 people per group.
- Shuffle


