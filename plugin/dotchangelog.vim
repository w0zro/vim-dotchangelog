def s:latestversion(versions: list<string>): string
    # very crude algorithm for finding latest semver version
    # there are bugs here no doubt, maybe one day this gets better
    var latest = null_list
    for version in versions
        var parts = split(version, '\.')
        if latest is null_list
            latest = parts
        # major check
        elseif parts[0] > latest[0]
            latest = parts
        # minor check
        elseif parts[0] == latest[0] && parts[1] > latest[1]
            latest = parts
        # patch check
        elseif parts[0] == latest[0] && parts[1] == latest[1] && parts[2] > latest[2]
            latest = parts
        endif
    endfor
    if latest is null_list
        return ''
    endif
    return join(latest, '.')
enddef

def g:DotChangelogEdit()
    if !exists('g:dotchangelog_name')
        echom 'please set g:dotchangelog_name in your vimrc'
        return
    endif

    if !isdirectory('.changelog')
        echom 'no .changelog directory found'
        return
    endif

    var versiondirs = map(globpath('.changelog/', '*', 1, 1), (_, v) => split(v, '/')[1])
    var latest = s:latestversion(versiondirs)
    if latest == ''
        echom 'no versions found in .changelog directory'
        return
    endif
    var dotchangelog_file = '.changelog/' .. latest .. '/' .. g:dotchangelog_name .. '.md'
    if filereadable(dotchangelog_file)
        execute ':e ' ..  fnameescape(dotchangelog_file)
        execute ':normal! G'
        return
    endif

    var dotblueprint_file = '.changelog/.blueprint/' .. g:dotchangelog_name .. '.md'
    if !filereadable(dotblueprint_file)
        echom dotblueprint_file .. ' not found'
        return
    endif

    execute ':e ' .. fnameescape(dotchangelog_file)
    execute ':0r ' .. fnameescape(dotblueprint_file)
    execute ':normal! G'
enddef
