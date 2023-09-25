export interface Profile {
    first_name:string,
    last_name:string,
    email:string
}

export interface SlackUser {
    name:string,
    id:string,
    deleted:boolean,
    profile:Profile
}

export interface SlackGroup {
    handle:string,
    id:string,
    deleted_by:string|null
}

export interface SlackUsersResponseObject {
    ok:boolean,
    members:SlackUser[],
    error?:string
}

export interface SlackGroupsResponseObject {
    ok:boolean,
    usergroups:SlackGroup[],
    error?:string
}

