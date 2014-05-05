class HIDManager
  def initialize
    @io_hid_manager = IOHIDManagerCreate(KCFAllocatorDefault, KIOHIDManagerOptionNone)
    IOHIDManagerSetDeviceMatching(@io_hid_manager, nil)
    IOHIDManagerScheduleWithRunLoop(@io_hid_manager, CFRunLoopGetMain(), KCFRunLoopDefaultMode)
    IOHIDManagerOpen(@io_hid_manager, KIOHIDManagerOptionNone)
  end

  def devices
    [].tap do |array|
      set = IOHIDManagerCopyDevices(@io_hid_manager)
      count = CFSetGetCount(set)
      pointer = Pointer.new(:object, count)
      CFSetGetValues(set, pointer)
      count.times { |i| array[i] = HIDDevice.new(pointer[i]) }
    end
  end
end
