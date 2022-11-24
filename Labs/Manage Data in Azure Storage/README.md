# Reference:

[Lab on Pluralsight](https://app.pluralsight.com/labs/detail/f46ec2f1-94f9-4049-b98a-069ea30327b5/toc)

https://learn.microsoft.com/en-us/azure/virtual-machines/windows/ps-common-ref

# Install Storage Explorer

Congratulations! Today is your first day on the job at Wired Brain Coffee – the world's largest online coffee supplier – as an Azure Administrator.

You will be responsible for providing support and maintenance to Wired Brain's Azure Storage infrastructure, using both Storage Explorer and AzCopy. 

Before starting any other tasks, Azure Storage Explorer needs to be installed. 

1. This lab should take about 10 minutes to spin up; wait for the environment to load before logging in to Azure.
2. Once the environment has successfully loaded, use the Email, Password, and button to the right of these instructions to log in to the Azure Portal. 
3. In the search bar at the top of the page, enter and click on Virtual machines.
4. At the Virtual machines page, click the bastion-01 link.

    Note: If you do not see such a link, then it is due to not waiting for resources to be created (see task 1). Click the Refresh button until it does show up, and then wait for its Status to change to Running (click Refresh to get an updated status). This will take about four to 10 minutes.

5. In the top row, click Connect > Bastion.
6. Enter the following credentials:

        Username: storagelab

        Password: psLAb!Us3sT3rrAF0rm

    Click Connect.

    Note: The virtual machine will open in a new browser tab (or window).

7. The first time you launch the virtual machine you will be prompted to allow the computer to be discoverable by other PCs and devices on this network. Click Yes.

    Note: 

        You may also be prompted by your browser to allow the VM to use the clipboard. Click Allow, or the equivalent, as it may vary depending on your browser and OS.

        You may also be prompted to access default privacy settings, in which case you should click Accept.
8. Open Microsoft Edge and, if prompted, click Complete Setup. 
9. Browse to this website within the VM to download Storage Explorer: https://azure.microsoft.com/en-us/features/storage-explorer

    Note: Even if not on Windows, note you will still need to use Ctrl-V to paste the url into the VM.
10. Click the Download now button to start the download, and then click Open file when it's done.
11. In the Select Setup Install dialog, click Install for me only (recommended) 

    Note: The Select Setup Install dialog may launch behind the Internet Explorer window. If you do not see the dialog immediately, look for a highlighted icon in the Windows toolbar, and click on that to bring the dialog to the front.

12. Choose I accept the agreement, click Install, then accept the defaults for the remainder of the installation by clicking Next a couple times, and finally click Finish.
    After a few minutes, Storage Explorer will launch automatically when the installation finishes.
13. A prompt titled Connect to Azure Storage will be displayed. Select the Subscription option, leave Azure selected on the next page and click Next.
14. Use the provided Azure credentials to the right of this text to sign in to Azure. 
15. The left-hand side of Storage Explorer then displays the ACCOUNT MANAGEMENT pane, and includes which subscription to connect to. Make sure every checkbox is checked, and click Open Explorer.

Once you click the Open Explorer button, you will see the list of Azure subscriptions with Storage Accounts.

Within the EXPLORER window, expand the dropdown for the ep-labs-learner section to view the Storage Accounts.  The Storage Account you will manage in this lab is called wiredstorage followed by a random set of numbers. For example: wiredstorage19870. This will be referred to as wiredstorage for the remainder of the lab.


# Manage Blobs with Storage Explorer

Wired Brain’s blob storage account has a single blob container whose contents are accessible by the public. Right now that blob container stores images for their website, and highly confidential business plans. In this challenge, you’ll use Storage Explorer to create a private blob container and move the business plans there.

1. On the left hand side of Storage Explorer, from the EXPLORER pane, expand ep-labs-learner... > Storage Accounts > wiredstorage > Blob Containers > images, and click on images.
2. Right-click on coffee-1.png, and from the pop-up menu click Copy URL. This will copy the URL directly to the clipboard.
3. To view the blob, go to Microsoft Edge and paste the URL into the address bar. In this case, the browser will display a graphic of a coffee mug. Right click on the image and select Save image as, then save it locally for later use. 
4. To download a blob, go to Storage Explorer, click on business-plan.pdf, and then click the Download button.

    Note: You may need to click the ... More button first, and from there, choose Download. This may be the case for future tasks.
5. Back in Storage Explorer, right-click wiredstorage > Blob Containers,  then click Create Blob Container from the popup menu.
6. Type internal-files and press enter to create a new blob container.
7. Click on the images container, then right-click business-plan.pdf and click Copy.
8. Click on internal-files, then click Paste (like Download and Copy, this is at the top of Storage Explorer's right pane.)

    You've now copied the pdf. You will now remove it from images.

9. Click on images, click business-plan.pdf, then click the Delete button in the toolbar. Click Yes when prompted.
10. Now, to simulate uploading sensitive documents to the proper folder, open File Explorer, navigate to the Documents folder, then right click in the file view area and select New > Text Document. 

11. Name the new file readme.txt. 
12. Back in Storage Explorer, in the images container, click on Upload > Upload Files.
13. Under Selected files, click the ... button.
14. Navigate to the readme.txt file you just created and select it, then click the Upload button.

    The file will be uploaded into the container, and will appear in the list.

    Note: You can view the progress of the upload operation in the Activities pane located below the file list.

Wired Brain's storage account now contains two blob containers: images and internal-files. You've successfully copied the confidential business-plan.pdf file to the internal-files container, and removed it from the images one. And you added a readme.txt file to the images container that will later be used to instruct folks to not upload sensitive information to that container.

# Manage Files with Storage Explorer

Wired Brain wants to use Azure Storage file shares to replace traditional networked file sharing. In this challenge you will use Storage Explorer to create the file shares, manage files, and obtain information to map Windows drives to an Azure Storage file share.

1. In Storage Explorer, right-click on the wiredstorage > File Shares, and from the pop-up menu click Create File Share 
2. Type wiredbrain-files and press enter.
3. Click the New Folder button, type top-secret-plans, then click OK.
4. Double click the top-secret-plans folder.
5. Click Upload > Upload Files…, then click the ... button.
6. Navigate to and select the coffee-1 image you saved in the previous challenge, then click Open. 
7. Click Upload. The image file will be uploaded to the file share.
8. To mount a Windows drive to the Azure file share, click the Connect VM button (which may be hidden – click the More button to access it). 
9. In the Connect File Share to VM window that appears, copy all the text that appears in the text box to the clipboard. Then click Close.

    Note: The text to copy will begin with the words net use and be several lines long. Remember in the VM you will need to use Ctrl + C to copy.
10. Open the Windows Command Prompt.
11. Paste the contents of the clipboard in to the command prompt, then use the arrow keys to navigate to the beginning of the text and replace [drive letter] with w:. 

12. Press Enter to execute the command.
13. Go to File Explorer and browse to the w: drive.

    Note: It will likely show as the wiredbrain-files network location.
14. Double-click the top-secret-plans folder.

    You will see the coffee-1 image file, and could double-click to view and edit it as if it were located locally on your machine.
15. Use File Explorer to delete the coffee-1.png file.
16. Switch back to Storage Explorer, and click the Refresh button.

    Note: As mentioned earlier, you may need to click the ... More button, and from there choose Refresh.

The coffee-1.png file no longer appears.

You have now set up an Azure File Share with a folder named top-secret-plans. That folder is empty because, after uploading a file to it using Storage Explorer, you mapped a Windows drive to the Azure File Share, and then deleted the file.

# Install AzCopy

Some tasks you’ll perform for Wired Brain include transferring blobs to and between storage accounts. You can use AzCopy for these tasks. But first, you need to install it.
1. Still in the VM, use Microsoft Edge to go to https://aka.ms/downloadazcopy-v10-windows, and to Save it to the Downloads folder.

    Note: This will download a zipped AzCopy application.
2. Click View downloads and then beside the downloaded .zip, click Open. 

3. The AzCopy zip file will be named similar to: azcopy_windows_amd64_10.8.0 (This was really a .zip file that was automatically extracted for you).

    Note: The last three numbers in the file name indicate the version, and may be different for you.

4. Copy this directory to c:\Users\storagelab

    Note: The result will be C:\Users\storagelab\azcopy_windows_amd64_10.8.0 (the last three numbers may vary).

5. Go to Storage Explorer, right click on the wiredstorage > Blob Containers > images, and click Get Shared Access Signature… .

6. In the Shared Access Signature dialog box, click Create.

7. Next to the URL field, click the Copy button, and store if for use in the last task. Click Close.

8. Go to the Command Prompt and run the command below: 

    cd c:\Users\storagelab\azcopy_windows_amd64_10.8.0

    Note: Make sure the directory name matches yours.

9. Type azcopy list ", then paste in the URI from the clipboard, then add a ". Press enter.

    Note: This is an example command:

    azcopy list "https://wiredstorage28669.blob.core.windows.net/images?sv=2019-10-10&st=2020-10-08T00%3A04%3A51Z&se=2020-10-09T00%3A04%3A51Z&sr=c&sp=rl&sig=z9dGLJmbYS9POw%2FEBDnTCp4wOcDnS62B%2BuegbbJsACI%3D"

You'll see a list of the contents in the images container. This is a quick way to verify that you have installed AzCopy correctly, and are using the proper permissions to connect to and read blob containers with it.

# Upload and Download Files with AzCopy

Wired Brain has many inventory reports that need to be uploaded to blob storage. The reports are all named similarly, so instead of manually selecting them with Storage Explorer, you will use AzCopy to upload many at a time.

First you will need a Shared Access Signature (SAS) token that gives permission to upload to a blob container.

1. In Storage Explorer right click wiredstorage > Blob Containers > internal-files, and click Get Shared Access Signature... from the popup menu.
2. Check the Write option, then click the Create button.
3. In the next window that appears, click the Copy button next to the URL text box. Click Close. Store this value for later use, for example, with Notepad.
4. In the Command Prompt, if you're not already in the azcopy directory, navigate there using cd:

    cd c:\Users\storagelab\azcopy_windows_amd64_10.8.0

    Note: The exact name of the azcopy_windows_amd64_10.8.0 directory may vary depending on the version of AzCopy downloaded in the previous challenge.

5. Now run the following after replacing <filepath> with the file path of the business-plan.pdf file from earlier, and <URL> with the URL you copied earlier: 

    azcopy copy "<filepath>" “<URL>”

    for example: azcopy copy "<filepath>" “<URL>”

    Note: This will upload that file to the internal-files container.

    If you had wanted to upload multiple files at a time, you would use this command: 

    azcopy copy "c:\storagelab\5-azcopy\*" "<URL>" --include-pattern "in*.txt;" 

    This uses wildcard matching. The in*.txt matches all files starting in in and ending in *.txt.

    You can specify multiple file matching patterns by using the --include-pattern parameter, separating each with a semicolon.

6. Now, to download files, enter the following: 

    azcopy copy "<URL>" c:\users\storagelab\downloads --recursive

    This just swaps the source and destination strings around in the azcopy copy command.

    The --recursive parameter instructs azcopy to apply the current command to every directory and file in the source.

You can check the Downloads directory, for example using Windows Explorer, to see the files you downloaded.

You've now used azcopy to both upload and download files.

# Sync Changes with AzCopy Automatically

AzCopy can compare the contents of one storage account against another account or a local directory, and can sync only the differences.

1. In Storage Explorer right click on the wiredstorage > Blob Containers > internal-files and click Get Shared Access Signature.

2. Check Write and Delete, then click Create.

3. Next to URL, click Copy, and store it for later use. Click Close.

4. Go to the Command Prompt.

5. If needed, type cd c:\Users\storagelab\azcopy_windows_amd64_10.8.0

    Note: The directory's name may vary depending on the version of AzCopy installed during a previous challenge.

6. Run the following command after replacing <URL> with the URL from earlier:

    azcopy sync “<URL>” “c:\Users\storagelab\Downloads”

    Note: This will copy all of the contents from the internal-files container to the c:\Users\storagelab\Downloads directory. 

7. Run the exact same command a second time. 

    Note: When viewing the output of the command, note that no files have been transferred. Everything is already in sync.

8. Using what you learned in a previous challenge, delete any file from the internal-files container using Storage Explorer.

9. In the Command Prompt, run the following (again replace <URL>):

    azcopy sync “<URL>” “c:\Users\storagelab\Downloads” --delete-destination true 

The files deleted from the internal-files container will now be deleted in the local directory.

AzCopy sync allows you to keep a destination directory, or storage account, up to date with changes in another location. And only the files that have changed will be modified at the destination.