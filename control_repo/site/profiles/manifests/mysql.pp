class profiles::mysql {
  include profiles::base

  class {'::mysql':}
}
