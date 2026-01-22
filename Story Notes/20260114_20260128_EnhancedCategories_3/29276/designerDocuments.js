define(["services/documentService",
    "plugins/dialog",
    "helpers/veoAjax",
    "durandal/system",
    "models/product",
    "helpers/messageHandler"],
    function (DocumentService, dialog, ajax, system, Product, messageHandler) {
        "use strict";

        /**
         * @constructor
         */
        var ctor = function () {
            this.accountID = ko.observable();
            this.organizationID = ko.observable();
            this.sessionID = ko.observable();
            this.applications = ko.observableArray([]);
            this.selectedApplication = ko.observable();
            this.products = ko.observableArray([]);
            this.selectedProduct = ko.observable();
            this.documents = ko.observableArray([]);
            this.initialApplication = undefined;
            this.initialProduct = undefined;

            this.selectedApplicationSubscription = undefined;
            this.selectedProductSubscription = undefined;

            this.hasDocuments = ko.computed(function () {
                return this.documents().length && this.documents().length > 0;
            }, this);

            this.ignoreDocumentLoad = false;
        };

        /**
         * Loads all of the applications, for the current account and organization, that designer documents can be set for.
         */
        ctor.prototype.loadApplications = async function () {
            this.products.removeAll();
            this.applications.removeAll();

            let applications = await DocumentService.getDesignerDocumentApplications(this.accountID(), this.organizationID());

            var hasAll = applications.some(application => {
                return application.toLowerCase() === "all";
            });

            if (!hasAll) {
                applications.unshift("All"); //add the "All" option to the front of the array
            }

            this.applications(applications);

            let allValue = applications.find(a => a.toLowerCase() === 'all');
            let defaultValue = this.initialApplication ? this.initialApplication : allValue;

            this.selectedApplication(defaultValue);
        };

        /**
         * Loads all of the products, for the currently selected application, that designer documents can be set for.
         */
        ctor.prototype.loadProducts = async function () {
            this.ignoreDocumentLoad = true;

            this.products.removeAll();

            let products = await DocumentService.getDesignerDocumentApplicationProducts(this.accountID(), this.organizationID(), this.selectedApplication());

            var hasAll = products.some(function (product) {
                return product.toLowerCase() === "all";
            });

            if (!hasAll) {
                products.unshift("All"); //add the "All" option to the front of the array
            }

            this.products(products);

            // clear flag so it can load documents
            this.ignoreDocumentLoad = false;

            let allValue = products.find(p => p.toLowerCase() === 'all');
            let defaultValue = this.initialProduct ? this.initialProduct : allValue;

            this.selectedProduct(defaultValue);
        };

        /**
         * This method is fired whenever the user selects an application
         */
        ctor.prototype.onApplicationSelected = function () {
            this.loadProducts();
        };

        /**
         * Click handler for the clear filter button. Resets the filter.
         */
        ctor.prototype.onClearFilterClicked = function () {
            //select the first application, which will reset the products list and select its first item
            this.initialApplication = undefined;
            this.initialProduct = undefined;

            if (this.applications().length && this.applications().length > 0) {
                this.selectedApplication(this.applications()[0]);
            }
        };

        /**
         * This method is fired whenever the user selects a product
         */
        ctor.prototype.onProductSelected = function () {
            if (!this.ignoreDocumentLoad) {
                this.loadDocuments();
            }

        };

        /**
         * Calling this method will request the list of designer documents from the server, based on the
         * current parameters stored by the dialog.
         */
        ctor.prototype.loadDocuments = function () {
            var self = this;

            this.documents.removeAll();

            if (!this.selectedApplication() || !this.selectedProduct()) {
                return; //don't load documents if there is no application or product selected
            }

            return DocumentService.getDesignerDocuments(this.accountID(), this.organizationID(), this.selectedApplication(), this.selectedProduct())
                .then(function (documents) {
                    self.documents(documents);
                });
        };

        /**
         * Click handler for document launch buttons. Opens the specified document in a new browser window.
         * @param {Object} document The document object that was clicked
         * @param {string} document.type The kind of document that was clicked; e.g. URL for web link, xls for excel, pdf for adobe document, etc.
         * @param {string} document.description The document's description, which will be used as the file name (in case the browser attempts to download the document)
         * @param {string} document.id The id of the document in the database system
         * @param {string} document.url The web address to the document, if it's type is URL.
         */
        ctor.prototype.onLaunchDocumentClicked = async function (document) {
            var params = {},
                url = '';

            // Check the type of the document, if it is a url, launch a web page, otherwise go to the action to retrieve designer documents.
            if (document.type !== 'URL') {

                //build the file name to use for this document. The description field defaults to the originally uploaded file name, so start with that
                var filename = document.description ? document.description.toLowerCase() : "document"; //if the description is empty, use a generic name
                var extension = "." + document.type.toLowerCase();

                //make sure the file name isn't longer than 50 characters. If it is, truncate it.
                if (filename.length > 50) {
                    filename = filename.substring(0, 50);
                }

                //if the description doesn't already contain the extension at the end, then add it
                if (filename.indexOf(extension) !== filename.length - extension.length) {
                    filename += extension;
                }

                params.accountID = this.accountID();
                params.organizationID = this.organizationID();
                params.documentID = document.id;
                params.fileName = filename;

                url = ajax.GetWebApiActionUrl("Document", "GetDesignerDocument", params);
            } else {
                url = document.url;
            }

            window.open(url);
        };

        /**
         * Call this method to close this dialog.
         */
        ctor.prototype.close = function () {
            dialog.close(this);
        };

        /**
         * Call this method to display this dialog in the ui. It returns a promise that resolves when the
         * dialog is closed. This is a convenience method. You can still directly use the Durandal App and/or
         * dialog classes to open this dialog.
         * @param {Object} settings An object that will be passed to the canActivate and activate methods
         * @param {string} settings.accountID The account to load the designer documents for
         * @param {string} settings.organizationID The organization that the designer documents belong to
         * @param {string} settings.sessionID The session that the designer documents belong to
         * @param {string} [settings.selectedApplication] Initializes the application drop down to this value, if supplied
         * @param {string} [settings.selectedProduct] Initializes the product drop down to this value, if supplied
         */
        ctor.prototype.show = function (settings) {
            return dialog.show(this, settings);
        };

        /**
         * The caller must supply the appropriate settings object, before this view can be displayed
         * @param {Object} settings An object that will be passed to the canActivate and activate methods
         * @param {string} settings.accountID The account to load the designer documents for
         * @param {string} settings.organizationID The organization that the designer documents belong to
         * @param {string} settings.sessionID The session that the designer documents belong to
         * @param {string} [settings.selectedApplication] Initializes the application drop down to this value, if supplied
         * @param {string} [settings.selectedProduct] Initializes the product drop down to this value, if supplied
         */
        ctor.prototype.canActivate = function (settings) {
            var allowActivation = settings && settings.accountID && settings.organizationID && settings.sessionID ? true : false;
            return allowActivation;
        };

        /**
         * Upon activating the dialog, we need to fetch the designer documents to initially display in the UI.
         * @param {Object} settings An object that will be passed to the canActivate and activate methods
         * @param {string} settings.accountID The account to load the designer documents for
         * @param {string} settings.organizationID The organization that the designer documents belong to
         * @param {string} settings.sessionID The session that the designer documents belong to
         * @param {string} [settings.selectedApplication] Initializes the application drop down to this value, if supplied
         * @param {string} [settings.selectedProduct] Initializes the product drop down to this value, if supplied
         */
        ctor.prototype.activate = function (settings) {
            //store settings
            this.accountID(settings.accountID);
            this.organizationID(settings.organizationID);
            this.sessionID(settings.sessionID);
            this.initialApplication = settings.initialApplication ? settings.initialApplication : undefined;
            this.initialProduct = settings.initialProduct ? settings.initialProduct : undefined;

            //setup event listeners for application and product selection
            this.selectedApplicationSubscription = this.selectedApplication.subscribe(this.onApplicationSelected, this);
            this.selectedProductSubscription = this.selectedProduct.subscribe(this.onProductSelected, this);

            return this.loadApplications();
        };

        /**
         * When this view is removed from the DOM, we need to dispose of our ko observable subscriptions
         */
        ctor.prototype.detached = function () {
            if (this.selectedApplicationSubscription) {
                this.selectedApplicationSubscription.dispose();
                this.selectedApplicationSubscription = undefined;
            }

            if (this.selectedProductSubscription) {
                this.selectedProductSubscription.dispose();
                this.selectedProductSubscription = undefined;
            }
        };

        return ctor;

    });