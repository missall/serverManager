require 'net/ssh'
require 'gchart'
class ServersController < ApplicationController
  layout 'server'
  before_filter :auth_current_user
  # GET /servers
  # GET /servers.xml
  def index
    @servers = Server.paginate(:page => params[:page],:per_page => 10).order('id asc')
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @servers }
    end
  end

  # GET /servers/1
  # GET /servers/1.xml
  def show
    @server = Server.find(params[:id])
    ssh = Net::SSH.start(@server.ip_address,@server.login_name,
      :password=> @server.password)
    @server.status = 1 if ssh
    ssh.exec!("export TERM=xterm-color")
    output = ssh.exec!("df -h /home")
    result = ssh.exec!('top -bn 1')
    @lines = []
    result.each_line do |line|
      @lines << line
    end
    @chart = diskspace(output)
    @server.update_attributes(params[:server])
  end
  
  def diskspace(output)
    lines = []
    output.each_line do |line|
      lines << line
    end
    
    line1 = lines[2] == nil ? lines[1].split(' ')[2] : lines[2].split(' ')[1]
    line2 = lines[2] == nil ? lines[1].split(' ')[3] : lines[2].split(' ')[2]
    disk_total = lines[2] == nil ? lines[1].split(' ')[1] : lines[2].split(' ')[0]
    used = lines[2] == nil ? lines[1].split(' ')[4] : lines[2].split(' ')[3]
    num1 = num2 = 0
    if (line1.include?("M"))
      num1 = line1.gsub('M',"").to_i
    elsif (line1.include?("G"))
      num1 = line1.gsub('G',"").to_i*1024
    else 
      num1 = line1.gsub('T',"").to_i*1024*1024
    end 
    
    if (line2.include?("M"))
      num2 = line2.gsub('M',"").to_i
    elsif (line2.include?("G"))
      num2 = line2.gsub('G',"").to_i*1024
    else 
      num2 = line2.gsub('T',"").to_i*1024*1024
    end
    @server.disk_total = disk_total
    @server.disk_used = line1
    @server.disk_avail = line2
    #puts num1 = lines[2].split(' ')[1].include?("G") ? lines[2].split(' ')[1].gsub('G',"").to_i*1024 : lines[2].split(' ')[1].gsub('T',"").to_i*1024*1024
    #puts num2 = lines[2].split(' ')[2].include?("G") ? lines[2].split(' ')[2].gsub('G',"").to_i*1024 : lines[2].split(' ')[2].gsub('T',"").to_i*1024*1024
    Gchart.pie_3d(:title => @server.name+" Disk Total:"+ disk_total + " Use:" + used, :size => '600x300',
                  :data => [num1.to_i, num2.to_i], :labels => ["Used:" + line1, "Avail:" + line2],
                  )    
  end

  # GET /servers/new
  # GET /servers/new.xml
  def new
    @server = Server.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @server }
    end
  end

  # GET /servers/1/edit
  def edit
    @server = Server.find(params[:id])
  end

  # POST /servers
  # POST /servers.xml
  def create
    @server = Server.new(params[:server])

    respond_to do |format|
      if @server.save
        format.html { redirect_to(@server, :notice => 'Server was successfully created.') }
        format.xml  { render :xml => @server, :status => :created, :location => @server }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @server.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /servers/1
  # PUT /servers/1.xml
  def update
    @server = Server.find(params[:id])

    respond_to do |format|
      if @server.update_attributes(params[:server])
        format.html { redirect_to(@server, :notice => 'Server was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @server.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /servers/1
  # DELETE /servers/1.xml
  def destroy
    @server = Server.find(params[:id])
    @server.destroy

    respond_to do |format|
      format.html { redirect_to(servers_url) }
      format.xml  { head :ok }
    end
  end
  
end
