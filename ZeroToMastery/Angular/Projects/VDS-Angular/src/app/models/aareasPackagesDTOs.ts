export class AareasGetProductPackageListReturnDTO {
    responseObject: Array<AareasPackageDTO>;
    constructor(responseObject: Array<AareasPackageDTO>) {
        this.responseObject = responseObject;
    }
}

export class AareasGetClientPackageReturnDTO {
    responseObject: AareasPackageDTO;
    constructor(responseObject: AareasPackageDTO) {
        this.responseObject = responseObject;
    }
}

export class AareasPackageDTO {
    packageName: string = '';
    packageGUID: string = '';
    productGUIDs: Array<SurfaceProductPairDTO> = [];
    constructor(packageName: string, packageGUID: string, productGUIDs: Array<SurfaceProductPairDTO>) {
        this.packageName = packageName;
        this.packageGUID = packageGUID;
        this.productGUIDs = productGUIDs;
    }
}

export class SurfaceProductPairDTO {
    surface: string = '';
    productGUID: string = '';
    constructor(surface: string, productGUID: string) {
        this.surface = surface;
        this.productGUID = productGUID;
    }
}