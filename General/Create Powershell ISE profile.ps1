if(!(test-path $profile.AllUsersCurrentHost))
  {new-item -type file -path $profile.AllUsersCurrentHost -Force}
  psEdit $profile.AllUsersCurrentHost