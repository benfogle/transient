Feature: Image Support
  In order to make it easier for a user to boot existing disk images,
  transient supports downloading Vagrant libvirt boxes. These can
  then be passed as disk images to QEMU

 Scenario: Download a single image
    Given a transient vm
      And a disk image "generic/alpine38:v3.0.2"
      And the vm is prepare-only
     When the transient command is run
     Then the return code is 0

 Scenario: Download an uncompressed image via http
    Given a transient vm
      And a disk image "test_http_file,http=https://github.com/ALSchwalm/transient-baseimages/releases/download/4/alpine-3.13.qcow2"
      And a backend "./artifacts/test-backend"
    And a ssh command "echo passed"
     When the vm runs to completion
     Then the return code is 0
      And stdout contains "passed"

 Scenario: Set a custom frontend
    Given a transient vm
      And a name "test-vm"
      And a disk image "generic/alpine38:v3.0.2"
      And a frontend "./artifacts/test-frontend"
      And the vm is prepare-only
     When the transient command is run
     Then the return code is 0
      And the file "test%2Dvm-0-generic%2Falpine38%3Av3.0.2" is in the frontend

 Scenario: Set a custom backend
    Given a transient vm
      And a disk image "generic/alpine38:v3.0.2"
      And a backend "./artifacts/test-backend"
      And the vm is prepare-only
     When the transient command is run
     Then the return code is 0
      And the file "generic%2Falpine38%3Av3.0.2" is in the backend

 Scenario: Use an image with the 'base' image spec
    Given a transient vm
      And a frontend "./artifacts/test-frontend"
      And a backend "./artifacts/test-backend"
      And a disk image "newimage,frontend=test-vm@generic/alpine38:v3.0.2"
      And the vm is prepare-only
     When the transient command is run
     Then the return code is 0
      And the file "newimage" is in the backend

Scenario: Use an image with nonexistent base spec
    Given a transient vm
      And a frontend "./artifacts/test-frontend"
      And a backend "./artifacts/test-backend"
      And a disk image "anothernewimage,frontend=test-vm@notexist"
      And the vm is prepare-only
     When the transient command is run
     Then the return code is 1

 Scenario: Delete a frontend image
    Given a transient delete command
      And a name "test-vm"
      And a frontend "./artifacts/test-frontend"
     When the transient command is run
     Then the return code is 0
      And the file "test%2Dvm-0-generic%2Falpine38%3Av3.0.2" is not in the frontend

 Scenario: Delete a backend image
    Given a transient delete command
      And a disk image "generic/alpine38:v3.0.2"
      And a backend "./artifacts/test-backend"
     When the transient command is run
     Then the return code is 0
      And the file "generic%2Falpine38%3Av3.0.2" is not in the backend

 Scenario: Delete a nonexistent file
    Given a transient delete command
      And a disk image "backend-does-not-exist"
      And a backend "./artifacts/test-backend"
     When the transient command is run
     Then the return code is 1

  Scenario: Use multiple image files
    Given a transient vm
      And a disk image "generic/alpine38:v3.0.2"
      And a disk image "generic/alpine38:v3.0.2"
      And a ssh command "ls /dev/sd*"
     When the vm runs to completion
     Then the return code is 0
      And stdout contains "sdb"

  Scenario: Use multiple image files without virtio-scsi
    Given a transient vm
      And a transient flag "-no-virtio-scsi"
      And a disk image "generic/alpine38:v3.0.2"
      And a disk image "generic/alpine38:v3.0.2"
      And a ssh command "ls /dev/sd*"
     When the vm runs to completion
     Then the return code is 0
      And stdout contains "sdb"

  Scenario: Connects image using virtio-scsi
    Given a transient vm
      And a disk image "generic/alpine38:v3.0.2"
      And a ssh command "ls -l /sys/block/sda"
     When the vm runs to completion
     Then the return code is 0
      And stdout contains "virtio"

  Scenario: Connect image with IDE
    Given a transient vm
      And a transient flag "-no-virtio-scsi"
      And a disk image "generic/alpine38:v3.0.2"
      And a ssh command "ls -l /sys/block/sda"
     When the vm runs to completion
     Then the return code is 0
      And stdout contains "ata"

  Scenario: Download a nonexistent image
    Given a transient vm
      And a disk image "djenerik/ahlpayn38:v3.0.2"
      And the vm is prepare-only
     When the transient command is run
     Then the return code is 1
      And there is no stack trace

  Scenario: Leave off a version specifier
    Given a transient vm
      And a disk image "generic/alpine38"
      And the vm is prepare-only
     When the transient command is run
     Then the return code is 1
      And there is no stack trace
