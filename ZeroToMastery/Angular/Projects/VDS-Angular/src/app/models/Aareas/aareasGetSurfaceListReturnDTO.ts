export class AareasGetSurfaceListReturnDTO {
    public responseObject: Array<AareasSceenRoomSurfaces> = [];
    constructor(responseObject: Array<AareasSceenRoomSurfaces>) {
        this.responseObject = responseObject;
    }
}

export class AareasSceenRoomSurfaces {
    public sceneId: number | null = null;
    public roomName: string = '';
    public renderableSurfaceList: Array<string> = [];
    constructor(sceneId: number, roomName: string, renderableSurfaceList: Array<string>) {
        this.sceneId = sceneId;
        this.roomName = roomName;
        this.renderableSurfaceList = renderableSurfaceList;
    }
}