Given("フィールドにはたくさんの生存者が存在する") do 
  Item.create_initial_items
  
  100.times do |i|
    transferring_new_survivor
  end  
  
end 

When("フィールドの時間がたくさん流れる") do    
  10.times do |i|
    put('/filed/current_location')  
    put('/filed/infection')    
  end
  
end

Then("フィールドにはゾンビや死亡者が存在する") do  
  expect(existence_of_zombies_or_death?).to eq(true)
end

def transferring_new_survivor
  params = {
    name: Faker::Japanese::Name.name,
    age: Faker::Number.between(from: 20, to: 60),
    inventory: [
      {
        name: Item.build_all_names.sample,
        count: Faker::Number.between(from: 1, to: 5)
      }
    ]
  }

  post('/players', params)  
end

def existence_of_zombies_or_death?
  fetch_filed_report[:infected_percentage_including_zombies] > 0.0
end