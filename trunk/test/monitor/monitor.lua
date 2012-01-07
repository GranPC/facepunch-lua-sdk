require( "facepunch" )
require( "connectors.luacurl" )
require( "CLRPackage" )

import( "System.Drawing" )
import( "System.Windows.Forms" )

local thread = facepunch.thread
local member = facepunch.member
local session = facepunch.session

local DefaultColour = Color.FromArgb( 17, 68, 119 )

local Colours = {}
Colours[ "Banned" ] = Color.FromArgb( 255, 0, 0 )
Colours[ "Gold Member" ] = Color.FromArgb( 160, 96, 0 )
Colours[ "Moderator" ] = Color.FromArgb( 0, 170, 0 )

local font = Font( "Segoe UI", 9, FontStyle.Regular, GraphicsUnit.Point, 0 )
local fontBold = Font( "Segoe UI", 9, FontStyle.Bold, GraphicsUnit.Point, 0 )

local function CleanHTML( str )
	return string.gsub( str, "%b<>", "" )
end

local function CreateThread( threadID, name, poster, newPosts )
	local threadPanel = Panel()
	local threadNameLabel = LinkLabel()
	local threadPosterLabel = Label()
	--local newPostsLabel = LinkLabel()

	threadNameLabel.ActiveLinkColor = Color.FromArgb( 30, 132, 234 )
	threadNameLabel.AutoSize = true
	threadNameLabel.DisabledLinkColor = Color.FromArgb( 50, 50, 50 )
	threadNameLabel.Font = fontBold
	threadNameLabel.LinkBehavior = LinkBehavior.HoverUnderline
	threadNameLabel.LinkColor = threadNameLabel.ActiveLinkColor
	threadNameLabel.Location = Point( 5, 0 )
	threadNameLabel.Name = "threadNameLabel_"..threadID
	threadNameLabel.Size = Size( 143, 10 )
	threadNameLabel.Padding = Padding( 6, 6, 0, 0 )
	threadNameLabel.Text = name
	--threadNameLabel.TextAlign = ContentAlignment.MiddleCenter
	threadNameLabel.VisitedLinkColor = threadNameLabel.LinkColor
	threadNameLabel.LinkClicked:Add( function()
	end )

	threadPosterLabel.AutoSize = true
	threadPosterLabel.Font = font
	threadPosterLabel.Location = Point( 5, 17 )
	threadPosterLabel.Name = "threadPosterLabel_"..threadID
	threadPosterLabel.Padding = Padding( 6, 6, 0, 0 )
	threadPosterLabel.Size = Size( 143, 21 )
	threadPosterLabel.TabIndex = 1
	threadPosterLabel.Text = poster

	threadPanel.Anchor = AnchorStyles.None
	threadPanel.Controls:Add( threadNameLabel )
	threadPanel.Controls:Add( threadPosterLabel )
	threadPanel.Name = "threadPanel_"..threadID
	threadPanel.Size = Size( 238, 50 )
	--threadPanel.BackColor = Color.FromArgb(120, 120, 120)

	return threadPanel
end

function InitializeWindow( uID )
	local err, user = 1, nil
	while err ~= 0 do
		err, user = member.getDataByUserID( uID )
	end

	Application.EnableVisualStyles()

	local w, h = 280, 250

	local parent = Form()

	local controlPanel = Panel()
	local controlPanelGradient = Panel()
	local openMonitorLink = LinkLabel()
	local currentlyLoggedInLabel = Label()
	local avatarPictureBox = PictureBox()
	local usernameLabel = Label()
	local userTitleLabel = Label()

	-- thread list

	local threadList = Panel()
	local threadListScroll = VScrollBar()

	controlPanel:SuspendLayout()

	controlPanel.Anchor = AnchorStyles.None
	controlPanel.BackColor = Color.FromArgb( 241, 245, 251 )
	controlPanel.BackgroundImageLayout = ImageLayout.None
	controlPanel.Controls:Add( controlPanelGradient )
	controlPanel.Controls:Add( openMonitorLink )
	controlPanel.Location = Point( 0, h - 57 )
	controlPanel.Name = "controlPanel"
	controlPanel.Size = Size( 264, 41 )
	controlPanel.TabIndex = 0

	local bgGradient = Bitmap.FromFile( "test/monitor/gradient.png" )

	controlPanelGradient.BackgroundImage = bgGradient
	controlPanelGradient.Location = Point( 0, 0 )
	controlPanelGradient.Name = "controlPanelGradient"
	controlPanelGradient.Size = Size( 264, 4 )
	controlPanelGradient.TabIndex = 1

	openMonitorLink.ActiveLinkColor = Color.FromArgb( 0, 102, 204 )
	openMonitorLink.Anchor = AnchorStyles.Bottom
	openMonitorLink.AutoSize = true
	openMonitorLink.DisabledLinkColor = Color.FromArgb( 50, 50, 50 )
	openMonitorLink.Font = font
	openMonitorLink.LinkBehavior = LinkBehavior.HoverUnderline
	openMonitorLink.LinkColor = openMonitorLink.ActiveLinkColor
	openMonitorLink.Location = Point( 59, 11 )
	openMonitorLink.Name = "openMonitorLink"
	openMonitorLink.Size = Size( 143, 15 )
	openMonitorLink.TabIndex = 0
	openMonitorLink.TabStop = true
	openMonitorLink.Text = "Open Facepunch Monitor"
	openMonitorLink.TextAlign = ContentAlignment.MiddleCenter
	openMonitorLink.VisitedLinkColor = openMonitorLink.LinkColor
	openMonitorLink.LinkClicked:Add( function()
		print( "TODO" )
	end )

	currentlyLoggedInLabel.AutoSize = true
	currentlyLoggedInLabel.Font = font
	currentlyLoggedInLabel.Location = Point( 5, 2 )
	currentlyLoggedInLabel.Name = "currentlyLoggedInLabel"
	currentlyLoggedInLabel.Padding = Padding( 6, 6, 0, 0 )
	currentlyLoggedInLabel.Size = Size( 132, 21 )
	currentlyLoggedInLabel.TabIndex = 1
	currentlyLoggedInLabel.Text = "Currently logged in as:"

	avatarPictureBox.ImageLocation = user.avatar
	avatarPictureBox.Location = Point( 6, 28 )
	avatarPictureBox.Name = "avatarPictureBox"
	avatarPictureBox.Size = Size( 39, 39 )
	avatarPictureBox.SizeMode = PictureBoxSizeMode.Zoom
	avatarPictureBox.TabIndex = 2
	avatarPictureBox.TabStop = false

	usernameLabel.AutoSize = true
	usernameLabel.Font = fontBold
	usernameLabel.ForeColor = Colours[ user.usergroup ] or DefaultColour
	usernameLabel.Location = Point( 51, 34 )
	usernameLabel.Name = "usernameLabel"
	usernameLabel.Size = Size( 67, 15 )
	usernameLabel.TabIndex = 3
	usernameLabel.Text = user.username

	userTitleLabel.AutoSize = true
	userTitleLabel.Location = Point( 51, 49 )
	userTitleLabel.Name = "userTitleLabel"
	userTitleLabel.Size = Size( 135, 15 )
	userTitleLabel.TabIndex = 4
	userTitleLabel.Margin = Padding( 3, 0, 0, 0 )
	userTitleLabel.Font = font
	userTitleLabel.Text = CleanHTML( user.usertitle or "" )

	controlPanel:ResumeLayout( false )
	controlPanel:PerformLayout()

	threadList.Anchor = AnchorStyles.None
--	threadList.BackColor = Color.FromArgb( 241, 35, 251 )
	threadList.BackgroundImageLayout = ImageLayout.None
	threadList.Controls:Add( threadListScroll )
	threadList.Location = Point( 11, 78 )
	threadList.Name = "threadList"
	threadList.Size = Size( 238, 110 )

	threadListScroll.Dock = DockStyle.Right
	threadListScroll.Name = "threadListScroll"
	threadListScroll.TabIndex = 2
	threadListScroll.Size = Size( 18, 110 )

	local latestThread = 0

	local threadControls = {}

	for i=1, 5 do
		local thread = CreateThread( 1, "Thread "..i, "Poster "..i, i*2 )
		thread.Location = Point( 0, 40 * (i - 1) )
		threadList.Controls:Add( thread )
		table.insert( threadControls, thread )
		latestThread = i
	end

	if ( latestThread >= 3 ) then
		threadListScroll.Visible = true
		threadListScroll.Maximum = ( 5 * (latestThread - 1) )
		threadListScroll.Value = 0
	else
		threadListScroll.Visible = false
	end

	threadListScroll.ValueChanged:Add( function()
		for k, v in pairs( threadControls ) do
			v.Location = Point( 0, 40 * (k - 1) - threadListScroll.Value * 5 )
		end
	end )

	parent.AutoScaleDimensions = SizeF( 6, 13 )
	parent.AutoScaleMode = AutoScaleMode.Font
	parent.BackColor = SystemColors.Window
	parent.ClientSize = Size( w, h )
	parent.ControlBox = false
	parent.Cursor = Cursors.Default
--	parent.DefaultCursor = parent.Cursor
	parent.MaximizeBox = false
	parent.MinimizeBox = false
	parent.MaximumSize = parent.ClientSize
	parent.MinimumSize = parent.MaximumSize
	parent.Name = "flyoutForm"

	-- TODO: Lua.NET bug - should report!
--	print(parent.WndProc)
--	function parent.WndProc(a,b,c,d,e) end

	local bounds = Screen.FromControl( parent ).WorkingArea
	local pos = Point( bounds.Right - w - 10, bounds.Bottom - h - 10 )
	parent.Location = pos

	parent.ShowIcon = false
	parent.ShowInTaskbar = false

	parent.Controls:Add( userTitleLabel )
	parent.Controls:Add( usernameLabel )
	parent.Controls:Add( currentlyLoggedInLabel )
	parent.Controls:Add( avatarPictureBox )
	parent.Controls:Add( controlPanel )
	parent.Controls:Add( threadList )

	parent.SizeGripStyle = SizeGripStyle.Hide
	parent.StartPosition = FormStartPosition.Manual
	parent.FormBorderStyle = FormBorderStyle.Sizable

	parent:ResumeLayout( false )
	parent:PerformLayout()
	parent:ShowDialog()

	return parent
end

-- InitializeWindow( 175313 ) -- test!

io.write( "Username: " )
local username = io.read()
io.write( "Password: " )
local password = io.read()
os.execute( "cls" )
local mySession = session( username, password )

local function login( loginSession )
	print( "Logging in as " .. username .. "..." )
	local error = -1
	while error ~= 0 do
		error = loginSession:login()
	end
	print( "Logged in!" )
	session.setActiveSession( loginSession )
end

login( mySession )


local error, securityToken = -1, nil
while error ~= 0 do
	error, securityToken = session.getSecurityToken()
end

local error, users = -1, nil
while error ~= 0 do
	error, users = member.searchUser( username, securityToken )
end

local uID

for id,name in pairs(users) do
	if name == username then
		uID = tonumber( id )
		break
	end
end

if not uID then
	print( "Could not find you!" )
else
	print( "Found current user: "..uID )
end

InitializeWindow( uID )