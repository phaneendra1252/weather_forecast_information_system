# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

admin_role = Role.create(name: "admin")
moderator_role = Role.create(name: "moderator")

user = User.new(name: "Surya", email: "ganni.phaneendra@gmail.com", password: "testing123", password_confirmation: "testing123")
user.role_ids = [admin_role.id, moderator_role.id]
user.save
