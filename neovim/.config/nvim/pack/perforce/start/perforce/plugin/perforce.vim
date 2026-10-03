
if !get(g:, 'perforce_enabled', v:false) || get(g:, 'perforce_loaded', v:false)
    finish
endif
let g:perforce_loaded = v:true

command! P4 call perforce#HomePage()
