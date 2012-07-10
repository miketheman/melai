# It doesn't look lik there is currently a defined method in aruba for 
# directories that should not exist. 
Given /^a directory named "([^"]*)" does not exist$/ do |directory|
  check_directory_presence([directory], false)
end
