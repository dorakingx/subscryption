'use client'

import { useState, useEffect } from 'react'
import { ethers } from 'ethers'

export default function Home() {
  const [account, setAccount] = useState(null)
  const [provider, setProvider] = useState(null)
  const [contract, setContract] = useState(null)
  const [plans, setPlans] = useState([])
  const [loading, setLoading] = useState(false)

  // Contract configuration
  const CONTRACT_ADDRESS = process.env.NEXT_PUBLIC_CONTRACT_ADDRESS || '0x...'
  const PYUSD_ADDRESS = process.env.NEXT_PUBLIC_PYUSD_ADDRESS || '0x...'

  useEffect(() => {
    connectWallet()
  }, [])

  const connectWallet = async () => {
    if (typeof window.ethereum !== 'undefined') {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' })
        setAccount(accounts[0])
        
        const provider = new ethers.BrowserProvider(window.ethereum)
        setProvider(provider)
        const signer = await provider.getSigner()
        
        // Initialize contract (you'll need the ABI)
        // const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer)
        // setContract(contract)
        
      } catch (error) {
        console.error('Error connecting wallet:', error)
      }
    }
  }

  const subscribe = async (planId) => {
    if (!contract) {
      alert('Please connect your wallet first')
      return
    }

    setLoading(true)
    try {
      // Get plan details
      const plan = await contract.getPlan(planId)
      
      // Approve PYUSD
      const pyusdContract = new ethers.Contract(PYUSD_ADDRESS, PYUSD_ABI, signer)
      const approveTx = await pyusdContract.approve(CONTRACT_ADDRESS, plan.price)
      await approveTx.wait()
      
      // Subscribe
      const subscribeTx = await contract.subscribe(planId)
      await subscribeTx.wait()
      
      alert('Subscription successful!')
    } catch (error) {
      console.error('Subscription error:', error)
      alert('Subscription failed: ' + error.message)
    } finally {
      setLoading(false)
    }
  }

  return (
    <main className="min-h-screen bg-gradient-to-br from-blue-50 to-purple-50 p-8">
      <div className="max-w-6xl mx-auto">
        <header className="text-center mb-12">
          <h1 className="text-5xl font-bold text-gray-900 mb-4">
            PYUSD Subscription Service
          </h1>
          <p className="text-xl text-gray-600">
            Decentralized subscriptions powered by PayPal USD
          </p>
        </header>

        <div className="mb-8 flex justify-center">
          {account ? (
            <div className="bg-green-100 border border-green-400 text-green-700 px-6 py-3 rounded-lg">
              Connected: {account.substring(0, 6)}...{account.substring(38)}
            </div>
          ) : (
            <button
              onClick={connectWallet}
              className="bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg transition"
            >
              Connect Wallet
            </button>
          )}
        </div>

        <div className="grid md:grid-cols-3 gap-6">
          <div className="bg-white p-6 rounded-xl shadow-lg border border-gray-200">
            <h3 className="text-2xl font-bold mb-2">Basic Plan</h3>
            <p className="text-4xl font-bold text-blue-600 mb-4">10 PYUSD</p>
            <p className="text-gray-600 mb-6">per month</p>
            <button
              onClick={() => subscribe(0)}
              disabled={loading || !account}
              className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-lg transition disabled:opacity-50"
            >
              Subscribe
            </button>
          </div>

          <div className="bg-white p-6 rounded-xl shadow-lg border border-gray-200">
            <h3 className="text-2xl font-bold mb-2">Pro Plan</h3>
            <p className="text-4xl font-bold text-blue-600 mb-4">25 PYUSD</p>
            <p className="text-gray-600 mb-6">per month</p>
            <button
              onClick={() => subscribe(1)}
              disabled={loading || !account}
              className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-lg transition disabled:opacity-50"
            >
              Subscribe
            </button>
          </div>

          <div className="bg-white p-6 rounded-xl shadow-lg border border-gray-200">
            <h3 className="text-2xl font-bold mb-2">Enterprise</h3>
            <p className="text-4xl font-bold text-blue-600 mb-4">100 PYUSD</p>
            <p className="text-gray-600 mb-6">per month</p>
            <button
              onClick={() => subscribe(2)}
              disabled={loading || !account}
              className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-lg transition disabled:opacity-50"
            >
              Subscribe
            </button>
          </div>
        </div>
      </div>
    </main>
  )
}
