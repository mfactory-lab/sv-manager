
if [ -d "{{ solana_bin_path }}/active_release/bin" ] ; then
  export PATH="$PATH:{{ solana_bin_path }}/active_release/bin"
fi