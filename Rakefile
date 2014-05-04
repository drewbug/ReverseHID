# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'ReverseHID'
  app.frameworks << 'IOBluetooth'
  app.frameworks_dependencies << 'IOKit'
  `patch -o ./bridge/IOKit.bridgesupport /System/Library/Frameworks/IOKit.framework/Resources/BridgeSupport/IOKit.bridgesupport ./bridge/IOKit.patch`
  app.bridgesupport_files << './bridge/IOKit.bridgesupport'
end
