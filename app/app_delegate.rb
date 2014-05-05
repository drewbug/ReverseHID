class AppDelegate
  def applicationDidFinishLaunching(notification)
    buildMenu
    buildWindow
    initHID
    initBluetooth
  end

  def buildWindow
    @mainWindow = NSWindow.alloc.initWithContentRect([[240, 180], [480, 360]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false)
    @mainWindow.title = NSBundle.mainBundle.infoDictionary['CFBundleName']
    @mainWindow.orderFrontRegardless
  end

  def initHID
    @hid_manager = HIDManager.new
    devices = hid_manager.devices

  # p devices.map { |device| IOHIDDeviceGetProperty(device, KIOHIDReportDescriptorKey) } (is http://prod.lists.apple.com/archives/usb/2013/Nov/msg00010.html still needed?)


  # Decision, don't merge "duplicates" in the GUI, because they might not be duplicates. Display each Page/Usage pair (named Page/Usage) in read-only table thingie, like in Sound Effects prefpane, but not even clickable (but still scrollable!)
  # Get Pages and Usages from USB HID doc, define as nested hash constant somewhere
  # TODO craft GUI, with on buttons like in Sharing PrefPane
  end

  def initBluetooth
    IOBluetoothL2CAPChannel.registerForChannelOpenNotifications(self, selector: 'new_bt_hid_control:', withPSM: 0x11, direction: KIOBluetoothUserNotificationChannelDirectionAny) #FIXME
    IOBluetoothL2CAPChannel.registerForChannelOpenNotifications(self, selector: 'new_bt_hid_interrupt:', withPSM: 0x13, direction: KIOBluetoothUserNotificationChannelDirectionAny) #FIXME

    sdp_entries = {'0001 - ServiceClassIDList' => [IOBluetoothSDPUUID.uuid16(KBluetoothSDPUUID16ServiceClassHumanInterfaceDeviceService)],
                   '0004 - ProtocolDescriptorList' => [[IOBluetoothSDPUUID.uuid16(KBluetoothSDPUUID16L2CAP), NSNumber.numberWithUnsignedShort(0x11)],
                                                       [IOBluetoothSDPUUID.uuid16(KBluetoothSDPUUID16HIDP)]],
                   '0006 - LanguageBaseAttributeIDList' => [NSNumber.numberWithUnsignedShort(0x100)], # REVIEW
                   '000D - AdditionalProtocolDescriptorLists' => [[[IOBluetoothSDPUUID.uuid16(KBluetoothSDPUUID16L2CAP), NSNumber.numberWithUnsignedShort(0x13)],
                                                                   [IOBluetoothSDPUUID.uuid16(KBluetoothSDPUUID16HIDP)]]],
                   '0009 - BluetoothProfileDescriptorList' => [IOBluetoothSDPUUID.uuid16(KBluetoothSDPUUID16ServiceClassHumanInterfaceDeviceService), NSNumber.numberWithUnsignedShort(0x0101)], # REVIEW
                   '0006 = AttributeIDList' => {'0201 - HIDParserVersion' => NSNumber.numberWithUnsignedShort(0x0111),
                                                '0202 - HIDDeviceSubclass' => '',
                                                '0203 - HIDCountryCode' => '',
                                                '0204 - HIDVirtualCable' => false,
                                                '0205 - HIDReconnectInitiate' => false,
                                                '0206 - HIDDescriptorList' => [],
                                                '0207 - HIDLANGIDBaseList' => [],
                                                '020E - HIDBootDevice' => false}}

    service_record = IOBluetoothSDPServiceRecord.withSDPServiceRecordRef \
      Pointer.new(:object).tap { |pointer| IOBluetoothAddServiceDict(sdp_entries, pointer) }.value

    server_handle = Pointer.new(:uint).tap { |pointer| service_record.getServiceRecordHandle(pointer) }.value
  end

  def new_bt_hid_control(notification, channel)
    channel.setDelegate(self)
    p 'new_bt_hid_control'
  end

  def new_bt_hid_interrupt(notification, channel)
    channel.setDelegate(self)
    p 'new_bt_hid_interrupt'
  end

  def l2capChannelData(channel, data: pointer, length: size)
    p 'l2capChannelData'
    data = [].tap { |array| size.times { |i| array[i] = pointer[i] } }
    p data
  end

  def l2capChannelOpenComplete(channel, status: error)
    p 'l2capChannelOpenComplete'
  end

  def l2capChannelClosed(channel)
    p 'l2capChannelClosed'
  end

  def l2capChannelReconfigured(channel)
    p 'l2capChannelReconfigured'
  end

  def l2capChannelWriteComplete(channel, refcon: refcon, status: error)
    p 'l2capChannelWriteComplete'
  end

  def l2capChannelQueueSpaceAvailable(channel)
    p 'l2capChannelQueueSpaceAvailable'
  end
end
