module PermissionsConcern
	extend ActiveSupport::Concern

	def is_normal_user?
		self.permision_level >= 1
	end

	def is_editor?
		self.permision_level >= 2
	end

	def is_admin?
		self.permision_level >= 3
	end

end