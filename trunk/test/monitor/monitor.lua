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

local TitleHTML = [[<html><style type="text/css">
.usertitle{white-space:normal;font-size:10px;clear:both;display:block;overflow:hidden;color:#3E3E3E;
font-family:Tahoma,Helvetica,Arial,Verdana!important;
line-height:1.230;
font:13px/1.231 arial,helvetica,clean,sans-serif;}
</style>~TITLE~</html>]]

local function CleanHTML( str )
	return string.gsub( str, "%b<>", "" )
end

function InitializeWindow( uID )
	local err, user = 1, nil
	while err ~= 0 do
		err, user = member.getDataByUserID( uID )
	end

	local parent = Form()

	local controlPanel = Panel()
	local controlPanelGradient = Panel()
	local openMonitorLink = LinkLabel()
	local currentlyLoggedInLabel = Label()
	local avatarPictureBox = PictureBox()
	local usernameLabel = Label()

	local userTitleLabel = Label()
	controlPanel:SuspendLayout()

	controlPanel.Anchor = AnchorStyles.None
	controlPanel.BackColor = Color.FromArgb( 241, 245, 251 )
	controlPanel.BackgroundImageLayout = ImageLayout.None
	controlPanel.Controls:Add( controlPanelGradient )
	controlPanel.Controls:Add( openMonitorLink) 
	controlPanel.Location = Point( 0, 73 )
	controlPanel.Name = "controlPanel"
	controlPanel.Size = Size( 264, 41 )
	controlPanel.TabIndex = 0

	local bgGradient = Bitmap.FromFile( "test/monitor/gradient.png" )

	controlPanelGradient.BackgroundImage = bgGradient
	controlPanelGradient.Location = Point( 0, 0 )
	controlPanelGradient.Name = "controlPanelGradient"
	controlPanelGradient.Size = Size( 264, 4 )
	controlPanelGradient.TabIndex = 1

	local font = Font( "Segoe UI", 9, FontStyle.Regular, GraphicsUnit.Point, 0 )
	local fontBold = Font( "Segoe UI", 9, FontStyle.Bold, GraphicsUnit.Point, 0 )

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

	parent.AutoScaleDimensions = SizeF( 6, 13 )
	parent.AutoScaleMode = AutoScaleMode.Font
	parent.BackColor = SystemColors.Window
	parent.ClientSize = Size( 280, 130 )
	parent.ControlBox = false
	parent.Cursor = Cursors.Default
--	parent.DefaultCursor = parent.Cursor
	parent.MaximizeBox = false
	parent.MinimizeBox = false
	parent.MaximumSize = Size( 280, 130 )
	parent.MinimumSize = parent.MaximumSize
	parent.Name = "flyoutForm"

	-- TODO: Lua.NET bug - should report!
--	print(parent.WndProc)
--	function parent.WndProc(a,b,c,d,e) end

	local bounds = Screen.FromControl( parent ).WorkingArea
	local pos = Point( bounds.Right - 290, bounds.Bottom - 140 )
	parent.Location = pos

	parent.ShowIcon = false
	parent.ShowInTaskbar = false

	parent.Controls:Add( userTitleLabel )
	parent.Controls:Add( usernameLabel )
	parent.Controls:Add( currentlyLoggedInLabel )
	parent.Controls:Add( avatarPictureBox )
	parent.Controls:Add( controlPanel )

	parent.SizeGripStyle = SizeGripStyle.Hide
	parent.StartPosition = FormStartPosition.Manual
	parent.FormBorderStyle = FormBorderStyle.Sizable

	parent:ResumeLayout( false )
	parent:PerformLayout()
	parent:ShowDialog()

	return parent
end

--InitializeWindow( 175313 ) -- test!

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