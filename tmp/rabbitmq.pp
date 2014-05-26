class { 'rabbitmq::server':
}

rabbitmq_user { 'snoozevzvds':
  password => 'snooze',
  provider => 'rabbitmqctl',
}

rabbitmq_vhost { 'snooze-vhostdzdz':
  ensure => present,
  provider => 'rabbitmqctl',
}

rabbitmq_user_permissions { 'snooze@snooze-vhost':
  configure_permission => '.*',
  read_permission      => '.*',
  write_permission     => '.*',
  provider => 'rabbitmqctl',
}

rabbitmq_plugin {'rabbitmq_stomp':
  ensure => present,
  provider => 'rabbitmqplugins',
}

rabbitmq_plugin {'rabbitmq_management':
  ensure => present,
  provider => 'rabbitmqplugins',
}

