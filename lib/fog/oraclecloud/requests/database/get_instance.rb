module Fog
  module OracleCloud
    class Database
      class Real

      	def get_instance(instance_id)
 					response = request(
            :expects  => 200,
            :method   => 'GET',
            :path     => "/paas/service/dbcs/api/v1.1/instances/#{@identity_domain}/#{instance_id}"
          )
          response
        end
      end

      class Mock
        def get_instance(name)
          response = Excon::Response.new

          if instance = self.data[:instances][name]
            case instance['status']
            when 'Terminating'
              if Time.now - self.data[:deleted_at][name] >= Fog::Mock.delay
                self.data[:deleted_at].delete(name)
                self.data[:instances].delete(name)
              end
            when 'In Progress'
              if Time.now - self.data[:created_at][name] >= Fog::Mock.delay
                self.data[:instances][name]['status'] = 'Running'
                instance = self.data[:instances][name]
                self.data[:created_at].delete(name)
              end
            when 'Maintenance'
              info = self.data[:maintenance_at][name]
              if Time.now - info['time'] >= Fog::Mock.delay
                self.data[:instances][name]['status'] = 'Running'
                self.data[:instances][name][info['attribute']] = info['value']
                self.data[:maintenance_at].delete(name)
              end
            end
            response.status = 200
            response.body = instance
            response
          else
            raise Fog::OracleCloud::Database::NotFound.new("Database #{name} does not exist");
          end
        end
      end
    end
  end
end