class Chat < ApplicationRecord

	def self.export(records=30)
		data = Chat.first(records)

		#current_out = $stdout
		#$stdout = File.new('chats.csv', 'w')
		#$stdout.sync = true
		
		puts "id,dpid,session,provider,message\n"
		Chat.first(records).each do |c|
			puts "#{c.id},#{c.dpid},#{c.session},#{c.provider},\"#{CGI.unescapeHTML(c.message)}\"\n" unless c.message.nil?
		end

		#$stdout = current_out

	end

	def self.parse_all!
		Chat.all.each do |c|
			c.parse
		end
	end


	def parse
		return nil if self.data.nil?
		return nil if self.message.present?

		begin
			@data = JSON.parse(self.data)
			if @data["messages"].present?
				self.message = @data["messages"].try(:[], 0).try(:[], "body")
				self.save!
			end

		rescue => e
			puts e
			return nil
		end
	end


end
