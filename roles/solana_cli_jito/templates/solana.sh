
if [ -d "{{ solana_app_path }}/active_release/bin" ] ; then
  export PATH="$PATH:{{ solana_app_path }}/active_release/bin"
fi