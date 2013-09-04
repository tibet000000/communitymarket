class GroupsController < ApplicationController
  # GET /groups
  # GET /groups.json
  def index
    if params[:zipcode]
      zipcode = params[:zipcode]
      @groups = Group.near(zipcode, 1000)
    else
      @groups = Group.all
    end
    @g_categories = GroupCategory.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @groups }
    end
  end
  
  # def nearby
  #     zipcode = 
  #     
  #     
  #     @g_categories = GroupCategory.all
  #     respond_to do |format|
  #       #format.html
  #       format.json  { render :json => @groups }
  #       #format.json { render :json => {:bathrooms => @bathrooms} }
  #       format.js   { render :nothing => true } 
  #      end        
  #   end
    
  # GET /groups/1
  # GET /groups/1.json
  def show
    @group = Group.find(params[:id])
    @posts = @group.posts
    @posts = Kaminari.paginate_array(@posts).page(params[:page]).per(35)
    
    if !signed_in?
      @user = User.new
    else
      @user = current_user
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.json
  def new
    
    @group = Group.new
    @categories = GroupCategory.all
    @group.assets.build
    @assets = @group.assets
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @group }
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  # POST /groups.json
  def create
    ip = request.location
    @group = Group.new(params[:group])
    params[:group][:member_ids] = (params[:group][:member_ids] << @group.member_ids).flatten

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render json: @group, status: :created, location: @group }
      else
        format.html { render action: "new" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.json
  def update
    @group = Group.find(params[:id])
    params[:group][:member_ids] = (params[:group][:member_ids] << @group.member_ids).flatten

    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { redirect_to root_path }
        format.js
        # format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        #         format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # NEEDS SUCCESS MESSAGE
  def private
    @group = Group.find(params[:group_id])
    params[:group][:member_ids] = (params[:group][:member_ids] << @group.member_ids).flatten
    
    respond_to do |format|
      if params[:password] == @group.password && @group.update_attributes(params[:group])
        flash[:success] = "Successfully joined #{@group.name}"
        format.html { redirect_to root_path }
        format.js
        # format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        #         format.json { head :no_content }
      else
        if params[:password] != @group.password
          flash.now[:wrong_password] = "Wrong Password"
        end
        format.html { render action: "show"}
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_url }
      format.json { head :no_content }
    end
  end
end
