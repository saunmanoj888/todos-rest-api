# Create Roles

roles_details = [
  { name: 'SuperAdmin', level: 20},
  { name: 'Supervisor', level: 15},
  { name: 'Admin', level: 10},
  { name: 'Reviewer', level: 10},
  { name: 'Member', level: 5}
]

Role.create(roles_details)

# Create Permission

permission_details = [
  { name: 'can_manage_users' },
  { name: 'can_read_users' },
]

Permission.create(permission_details)

# Set permission for all the roles
manage_roles = Role.where(name: ['SuperAdmin', 'Supervisor', 'Admin', 'Reviewer'])
manage_permission = Permission.find_by(name: 'can_manage_users')
manage_roles.each do |role|
  role.permissions << manage_permission
end

read_roles = Role.where(name: 'Member')
read_permission = Permission.find_by(name: 'can_read_users')
read_roles.each do |role|
  role.permissions << read_permission
end

# Create Super User

super_user = User.create(username: 'superadmin', password: 'qwerty', first_name: 'super', last_name: 'admin', role: 'Admin', email: 'ad@example.com')
super_user.roles << Role.find_by(name: 'SuperAdmin')
