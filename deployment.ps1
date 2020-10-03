param ([Parameter(Mandatory=$true)][string] $repourl)

function Start-Deployment {
    param (
        $WebAppName,
        $RepositoryUrl,
        $ResourceGroupName
    )

    Show-DeploymentStartMessage
    
    $success = az webapp deployment source config --resource-group $ResourceGroupName --name $WebAppName --repo-url $RepositoryUrl
    if($success) {
        Terminate -Message "--------------- Deploy Concluido ---------------`n`nUrl: https://$($WebAppName).azurewebsites.net`n"
    }
    else {
        Terminate -Message "------------- Erro ao executar deploy -------------"
    }
}

function Show-DeploymentStartMessage {
    Write-Output ""
    Write-Output "--------------- Iniciando Deploy da Aplicacao ------------------"
    Write-Output "Aguarde..."
}

function Request-WebApp {
    param (
        $ResourceGroupName,
        $AppServiceName
    )

    $ServiceName = Read-Host -Prompt 'Informe o nome do Servico de Aplicativo'

    $success = az webapp show --name $ServiceName --resource-group $ResourceGroupName

    if(!$success) {
        Confirm-Dialog -Title "Servico de Aplicativo nao encontrado" -Question "Deseja criar o novo Servico de Aplicativo $($ServiceName)?"
        $result = az webapp create --resource-group $ResourceGroupName --plan $AppServiceName --name $ServiceName 
    }

    return $ServiceName
}

function Request-AppSevicePlan {
    param (
        $ResourceGroupName
    )

    $AppName = Read-Host -Prompt 'Informe o nome do plano do aplicativo'

    $success = az appservice plan show --name $AppName --resource-group $ResourceGroupName

    if(!$success) {
        Confirm-Dialog -Title "Plano de Servicos de Aplicativo nao encontrado" -Question "Deseja criar o novo Plano de Servicos de Aplicativo $($AppName)?"
        $result = az appservice plan create --resource-group $ResourceGroupName --name $AppName --sku FREE
    }

    return $AppName
}

function Request-ResourceGroupName {
    $GroupName = Read-Host -Prompt 'Informe o nome do grupo de recursos'

    $success =  az group show --name $GroupName

    if(!$success) {
        Confirm-Dialog -Title "Grupo de Recursos nao encontrado" -Question "Deseja criar o novo Grupo de Recursos $($GroupName)?"
        $result = az group create --location "brazilsouth" --name $GroupName
    }

    return $GroupName
}

function Request-LoginAzure {
    Write-Output "------------------ Autenticacao no portal Azure ------------------"

    $success = az login

    if($success){
        Show-Authenticated
    }
    else {
        Terminate -Message "------------- Usuario nao autenticado -------------"
    }
}

function Confirm-Dialog {
    param (
        $Title,
        $Question
    )
    $choices  = '&Sim', '&Cancelar'
    $host.ui.RawUI.ForegroundColor = 'White'
    $decision = $Host.UI.PromptForChoice($Title, $Question, $choices, 1)
    if ($decision -eq 1) {
        Terminate -Message "------------- Cancelado -------------"
    } 
}

function Terminate {
    param($message)
    Write-Output $message
    exit
}

function Show-Authenticated {
    $host.ui.RawUI.ForegroundColor = 'White'
    Write-Output "--------------- Autenticado ------------------"
    Write-Output ""
}

function Welcome-Message {
    Write-Output "--------  Deploy automatizado do ambiente DevOpsChallenge --------"
    Write-Output "--------------------  Criado por: msalvexx -----------------------"
    Write-Output ""
}

Welcome-Message
Request-LoginAzure
$GroupName = Request-ResourceGroupName
$AppServiceName = Request-AppSevicePlan -ResourceGroupName $GroupName
$WebApp = Request-WebApp -AppServiceName $AppServiceName -ResourceGroupName $GroupName
Start-Deployment -WebAppName $WebApp -ResourceGroupName $GroupName -RepositoryUrl $repourl
