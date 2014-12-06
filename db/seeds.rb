# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

admin_role = Role.where(name: "admin").first_or_create
moderator_role = Role.where(name: "moderator").first_or_create

if User.where(email: "ganni.phaneendra@gmail.com").blank?
	user = User.new(name: "Surya", email: "ganni.phaneendra@gmail.com", password: "testing123", password_confirmation: "testing123")
	user.role_ids = [admin_role.id, moderator_role.id]
	user.save
end

imd_states_with_codes = {
	0 => "All States",
	1 => "ANDAMAN & NICOBAR",
	2 => "ANDHRA PRADESH",
	3 => "ARUNACHAL PRADESH",
	4 => "ASSAM",
	48 => "BHUTAN",
	36 => "BIHAR",
	47 => "CHANDIGARH",
	5 => "CHATTISGARH",
	37 => "DAMAN & DIU",
	32 => "DELHI",
	7 => "GOA",
	8 => "GUJARAT",
	9 => "HARYANA",
	10 => "HIMACHAL PRADESH",
	40 => "JAMMU & KASHMIR",
	11 => "JHARKHAND",
	12 => "KARNATAKA",
	13 => "KERALA",
	49 => "LABORATORY",
	14 => "LAKSHADWEEP",
	15 => "MADHYA PRADESH",
	16 => "MAHARASHTRA",
	44 => "MANIPUR",
	38 => "MEGHALAYA",
	43 => "MIZORAM",
	18 => "NAGALAND",
	35 => "NCR",
	20 => "ORISSA",
	46 => "PUDUCHERRY",
	22 => "PUNJAB",
	23 => "RAJASTHAN",
	24 => "SIKKIM",
	25 => "TAMIL NADU",
	41 => "TRIPURA",
	26 => "UTTAR PRADESH",
	33 => "UTTARAKHAND",
	28 => "WEST BENGAL"
}

imd_states_with_codes.each do |code, state_name|
	if ImdState.where(code: code).blank?
		ImdState.create(code: code, name: state_name)
	end
end