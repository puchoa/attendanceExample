require "sinatra"
require_relative "./models.rb"
require_relative "api_authentication.rb"
require "date"


get "/" do

  erb :index
end


# View all users info
get "/user/all" do
  api_authenticate!

  u = User.all
  halt 200,  u.to_json

end

#Read  return user account
get "/user/myAccount" do
  api_authenticate!
  halt 200, current_user.to_json
end


#PATCH Update user password
patch "/user/:id/" do
  api_authenticate!

  if params[:id]
    if params[:id].to_i == current_user.id
      if params["old_password"] and params["new_password"]
        u = User.first(id: params[:id], password: params["old_password"])
        if u
          u.password = params["new_password"]
          u.save
          halt 200, {"message": "password updated"}.to_json
        else
          halt 404, {"message": "Not Found"}.to_json
        end
      else
        message = "Missing either old and or new password"
        halt 400, {"message": message}.to_json
      end
    else
      halt 401, {"message": "Unauthorized"}.to_json
    end

  else
    halt 401, {"message": "Unauthorized"}.to_json
  end
end

#PATCH upgrade user account
patch "/user/:id/upgrade" do
  api_authenticate!
  if params[:id]
    if current_user.id == params[:id].to_i
      if current_user.admin == false
        current_user.admin = true
        current_user.save
        halt 200, {"message": "Account upgraded"}.to_json
      else
        halt 400, {"message": "Account is already upgraded"}.to_json
      end
    else
      halt 401, {"message": "Unauthorized"}.to_json
    end
  else
    halt 401, {"message": "Unauthorized"}.to_json
  end
end

#PATCH downgrade user account
patch "/user/:id/downgrade" do
  api_authenticate!
  if params[:id]
    if current_user.id == params[:id].to_i
      if current_user.admin == true
        current_user.admin = false
        current_user.save
        halt 200, {"message": "Account downgraded"}.to_json
      else
        halt 400, {"message": "Account is already downgraded"}.to_json
      end
    else
      halt 401, {"message": "Unauthorized"}.to_json
    end
  else
    halt 401, {"message": "Unauthorized"}.to_json
  end
end

#CREATE Class
post "/class/create" do

  api_authenticate!
  if current_user.admin == true

    if params["class_name"]
      a = Classroom.first(user_id: current_user.id, class_name: params["class_name"])
      if a
        message = a.class_name + " already exists"
        halt 409, {"message": message}.to_json
      else
        c = Classroom.new
        c.class_name = params["class_name"]
        c.user_id = current_user.id
        c.save
        halt 201, c.to_json
      end
    else
      message = "Missing class name"
      halt 400, {"message": message}.to_json
    end
  else
    halt 401, {"message": "Unauthorized"}.to_json
  end

end

#PATCH Class name
patch "/class/edit" do
  api_authenticate!
  id = params["class_id"].to_i
  name = params["class_name"]

  if current_user.admin == true
    if id
      u = Classroom.first(id: id, user_id: current_user.id)
      if u and name
        u.class_name = name
        u.save

        attend = Attendance.all(class_id: id, user_id: current_user.id)
        if attend
          attend.each do |update|
            update.class_name = name
            update.save
          end
        end
        message = "Class name was updated"
        halt 200, {"message": message}.to_json
      else
        halt 404, {"message": "Not Found"}.to_json
      end
    else
      message = "Missing class id"
      halt 400, {"message": message}.to_json
    end
  else
    halt 401, {"message": "Unauthorized"}.to_json
  end
end

#DELETE Class
delete "/class/delete" do
  api_authenticate!
  if params["class_id"]
    c = Classroom.first(id: params["class_id"], user_id: current_user.id)
    if c
      name = c.class_name
      c.destroy!
      message = name + " was deleted"
      halt 200, {"message": message}.to_json

    else
      halt 404, {"message": "Not Found"}.to_json
    end
  else
    message = "Missing class id"
    halt 400, {"message": message}.to_json
  end
end

#READ class name
get "/class/:id" do
  api_authenticate!
  if params[:id]
    c = Classroom.first(id: params[:id])
    if c
      halt 200, c["class_name"].to_json
    else
      halt 404, {"message": "Not Found"}.to_json
    end
  else
    message = "Missing class id"
    halt 400, {"message": message}.to_json
  end
end
